{ config, pkgs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
    
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = "1";
  boot.kernelPackages = config.boot.zfs.packages.latestCompatibleLinuxPackages; 
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.ntp.enable = true;
  time.timeZone = "America/New_York";
  
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank" ];
  networking.hostId = "abcd1234";
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  services.nfs.server.enable = true;

  boot.plymouth.enable = true;

  services.fwupd.enable = true;

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
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      extraPackages = [ pkgs.zfs ];
    };
  };

 # virtualisation.oci-containers.containers."jellyfin" = {
 # 	autoStart = true;
 # 	image = "jellyfin/jellyfin";
 #	 volumes = [
 # 	  "/media/jellyfin/config:/config"
 # 	  "/media/jellyfin/cache:/cache"
 # 	  "/media/jellyfin/movies:/movies"
 # 	  "/media/jellyfin/tv:/tv"	
 # 	];
 # 	ports = [ "8096:8096"];
 # 	environment = {
 # 		JELLYFIN_LOG_DIR = "/log";
 # 	};
 # };

  users.mutableUsers = false;
  users.users.nikola = {
    isNormalUser = true;
    initialPassword = "abc123";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVDmZyOI0fRbQH3Wm23XeuJ9ykbiFy6VBPvmKgTYXdm nikola@laptop" ];
  };

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

  #services.tailscale.enable = true;
  #systemd.services.tailscale-autoconnect = {
  #description = "Automatic connection to Tailscale";

  #after = [ "network-pre.target" "tailscale.service" ];
  #wants = [ "network-pre.target" "tailscale.service" ];
  #wantedBy = [ "multi-user.target" ];

  #serviceConfig.Type = "oneshot";
  #script = with pkgs; ''
  #  sleep 2

  #  status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
  #  if [ $status = "Running" ]; then # if so, then do nothing
  #    exit 0
  #  fi

  #  ${tailscale}/bin/tailscale up -authkey tskey-auth-kwecwu1CNTRL-ahD1vLK13uKhuFCJbxM9mKMiynV7VJxK
  #'';
  #};

  services.openssh = {
    enable = true;
    passwordAuthentication = true;
    allowSFTP = false;
    challengeResponseAuthentication = false;
    extraConfig = ''
      AllowTcpForwarding yes
      X11Forwarding no
      AllowAgentForwarding no
      AllowStreamLocalForwarding no
      AuthenticationMethods publickey
    '';
  };

  networking.firewall = {
  	enable = true;
  	allowedTCPPorts = [ 22 80 443 8096 8384 ];
  	allowedUDPPorts = [ 22 80 443 8096 8384 ];
    #trustedInterfaces = [ "tailscale0" ];
    #allowedUDPPorts = [ config.services.tailscale.port ];
  };

  nix.settings.sandbox = true;

  system.stateVersion = "23.05";

}
