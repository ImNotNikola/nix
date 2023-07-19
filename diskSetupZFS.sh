set -ex

DISK=(/dev/sdX)

PART_GPT="gpt"
PART_EFI="efi"
PART_ROOT="rpool"

ZFS_ROOT="rpool"

ZFS_ROOT_VOL="nixos"

MNT=$(mktemp -d)

set +x

MAINCFG="/mnt/etc/nixos/configuration.nix"
HWCFG="/mnt/etc/nixos/hardware-configuration.nix"

set -x

sgdisk --zap-all ${DISK}

parted --script --align=optimal  "${DISK}" -- \
mklabel gpt \
mkpart EFI 2MiB 1GiB \
mkpart rpool 1GiB 100% \
set 1 esp on 

# Wait for a bit to let udev catch up and generate /dev/disk/by-partlabel.
sleep 3s
partprobe "${DISK}"
udevadm settle

# Create the root pool
zpool create \
	-o ashift=12 \
	-o autotrim=on \
	-O acltype=posixacl \
	-O compression=zstd \
	-O dnodesize=auto \
        -O normalization=formD \
	-O relatime=on \
	-O xattr=sa \
	-O mountpoint=none \
	-R /mnt \
	${ZFS_ROOT} ${ZFS_ROOT_VDEV} /dev/disk/by-partlabel/${PART_ROOT}*

zfs create -o mountpoint=legacy -o compression=lz4 ${ZFS_ROOT}/${ZFS_ROOT_VOL}
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/home
zfs create -o atime=off ${ZFS_ROOT}/${ZFS_ROOT_VOL}/nix
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/root
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/usr
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}/var
zfs create ${ZFS_ROOT}/${ZFS_ROOT_VOL}containers/
zfs create -o mountpoint=/boot ${ZFS_ROOT}/${ZFS_ROOT_VOL}/boot

# Create, mount and populate the efi partitions
mkfs.vfat -n EFI /dev/disk/by-partlabel/${PART_EFI}
mkdir -p /mnt/boot/${PART_EFI}
mount -t vfat /dev/disk/by-partlabel/${PART_EFI} /mnt/boot/${PART_EFI}

# Make sure we won't trip over zpool.cache later
mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache

# Generate and edit configs
nixos-generate-config --root /mnt

cp /mnt/etc/nixos/configure.nix /mnt/etc/nixos/configure.nix.old
cp /tmp/configureation.nix /mnt/etc/nixos/configuration.nix

sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' ${HWCFG}

ADDNR=$(awk '/^  fileSystems."\/" =$/ {print NR+3}' ${HWCFG})
sed -i "${ADDNR}i"' \      neededForBoot = true;' ${HWCFG}

ADDNR=$(awk '/^  fileSystems."\/boot" =$/ {print NR+3}' ${HWCFG})
sed -i "${ADDNR}i"' \      neededForBoot = true;' ${HWCFG}

sed -i "s|\"abcd1234\"|\"$(head -c4 /dev/urandom | od -A none -t x4| sed 's| ||g' || true)\"|g" ${MNT}/etc/nixos/configuration.nix

set +x
echo "nixos-install --no-root-passwd --root /mnt"
echo "umount -Rl /mnt"
echo "zpool export -a"
echo "swapoff -a"
echo "reboot"
