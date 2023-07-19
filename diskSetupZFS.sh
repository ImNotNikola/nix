set -ex

DISK=(/dev/disk/by-id/ata-Samsung_SSD_870_EVO_250GB_S6PDNM0T534366P)

set +x

MAINCFG="/mnt/etc/nixos/configuration.nix"
HWCFG="/mnt/etc/nixos/hardware-configuration.nix"

set -x

sgdisk --zap-all ${DISK}
parted --script --align=optimal  "${DISK}" -- \
mklabel gpt \
mkpart efi 0% 1GiB \
mkpart root 1GiB 100% \
set 1 esp on 

sleep 3s
partprobe "${DISK}"
udevadm settle

zpool create \
	-o ashift=12 \
	-o autotrim=on \
	-O acltype=posixacl \
	-O compression=on \
	-O dnodesize=auto \
        -O normalization=formD \
	-O relatime=on \
	-O xattr=sa \
	-O mountpoint=none \
	root /dev/disk/by-partlabel/root

zfs create -o mountpoint=legacy -o compression=lz4 root/local
zfs create -o mountpoint=legacy -o compression=lz4 root/user
zfs create -o mountpoint=legacy -o compression=lz4 root/user/home
zfs create -o mountpoint=legacy -o compression=lz4 root/local/nix
zfs create -o mountpoint=legacy -o compression=lz4 root/system
zfs create -o mountpoint=/boot root/boot

mkfs.vfat -n EFI /dev/disk/by-partlabel/efi
mkdir -p /mnt/boot/efi
mount -t vfat /dev/disk/by-partlabel/efi /mnt/boot/efi

mkdir -p /mnt/etc/zfs/
rm -f /mnt/etc/zfs/zpool.cache
touch /mnt/etc/zfs/zpool.cache
chmod a-w /mnt/etc/zfs/zpool.cache
chattr +i /mnt/etc/zfs/zpool.cache

nixos-generate-config --root /mnt

cp /tmp/configureation.nix /mnt/etc/nixos/configuration.nix

sed -i 's|fsType = "zfs";|fsType = "zfs"; options = [ "zfsutil" "X-mount.mkdir" ];|g' ${HWCFG}

ADDNR=$(awk '/^  fileSystems."\/" =$/ {print NR+3}' ${HWCFG})
sed -i "${ADDNR}i"' \      neededForBoot = true;' ${HWCFG}

ADDNR=$(awk '/^  fileSystems."\/boot" =$/ {print NR+3}' ${HWCFG})
sed -i "${ADDNR}i"' \      neededForBoot = true;' ${HWCFG}

sed -i "s|\"abcd1234\"|\"$(head -c4 /dev/urandom | od -A none -t x4| sed 's| ||g' || true)\"|g" ${MAINCFG}

echo "nixos-install --no-root-passwd --root /mnt"
echo "umount -Rl /mnt"
echo "zpool export -a"
echo "swapoff -a"
echo "reboot"
