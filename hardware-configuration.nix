{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "ahci" "nvme" "xhci_pci" "usbhid" "uas" "sd_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/3a05c6ac-94d3-4911-9337-0eb1cdebafcf";
      fsType = "ext4";
    };

  fileSystems."/boot" =a
    { device = "/dev/disk/by-uuid/576D-67F6";
      fsType = "vfat";
    };

  fileSystems."/containers" = {
    device = "nvme/containers";
    options = [ "bind" ];
  };

  fileSystems."/data" = {
    device = "tank/data";
    options = [ "bind" ];
  };
  
  swapDevices = [ ];

  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
