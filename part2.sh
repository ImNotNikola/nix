MAINCFG="/mnt/etc/nixos/configuration.nix"
HWCFG="/mnt/etc/nixos/hardware-configuration.nix"

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
