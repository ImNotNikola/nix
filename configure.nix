# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
    
  boot.loader.systemd-boot.enable = true;
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = "1";
  # boot.loader.efi.canToutchEfiVariables = true;
  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";
  services.ntp.enable = true;
  time.timeZone = "America/New_York";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  boot.supportedFilesystems = [ "btrfs" ];

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank" ];
  networking.hostId = "fe9c7f2a";
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  services.nfs.server.enable = true;


  boot.plymouth.enable = true;

  services.fwupd.enable = true;

  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # sound.enable = true;
  # hardware.pulseaudio.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;
  networking.networkmanager.enable = true;
  networking.interfaces.enp5s0.ipv4.addresses = [ {
    address = "192.168.0.3";
    prefixLength = 24;
  } ];

  networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "192.168.0.1" ];
  networking.hostName = "server";

  virtualisation = {
    podman = {
      enable = true;
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  virtualisation.oci-containers.containers."jellyfin" = {
  	autoStart = true;
  	image = "jellyfin/jellyfin";
  	volumes = [
  	  "/media/jellyfin/config:/config"
  	  "/media/jellyfin/cache:/cache"
  	  "/media/jellyfin/movies:/movies"
  	  "/media/jellyfin/tv:/tv"	
  	];
  	ports = [ "8096:8096"];
  	environment = {
  		JELLYFIN_LOG_DIR = "/log";
  	};
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  # };

 services.syncthing = {
 	enable = true;
 	user = "syncthing";
 	guiAddress = "0.0.0.0:8384";
  };
 
 users.users.nikola = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
  # openssh.authorizedKeys.keys = [ pubkey.nikola ]  
    };


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];
  environment.systemPackages = with pkgs; [
    micro
    wget
    curl
    git
    bat
    ripgrep
    zsh
    duf
    ncdu
    neofetch
    htop
    rsync
    shadow
    tailscale
  ];

  services.tailscale.enable = true;
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };
  
  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
  	enable = true;
  	allowedTCPPorts = [ 22 80 443 8096 8384 ];
  	allowedUDPPorts = [ 22 80 443 8096 8384 ];
  };
  
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  nix.settings.sandbox = true;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

}
