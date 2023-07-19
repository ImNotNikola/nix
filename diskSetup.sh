DISK=(/dev/disk/by-id/ata-Samsung_SSD_870_EVO_250GB_S6PDNM0T534366P)

sgdisk --zap-all ${DISK}
parted --script --align=optimal  ${DISK} -- \
mklabel gpt \
mkpart ESP fat32 0% 1GiB \
mkpart root 1GiB 100% \
set 1 esp on 

partprobe ${DISK}
udevadm settle

mkfs.ext4 -L nixos ${DISK}

zfs create -o mountpoint=/boot root/boot
mkfs.fat -F 32 -n boot /dev/disk/${DISK}
mkdir -p /mnt/boot
mount -t vfat /dev/disk/by-label/boot /mnt/boot

nixos-generate-config --root /mnt

echo "done!"
