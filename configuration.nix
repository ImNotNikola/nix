{ config, pkgs, ... }:

{
  imports =
    [ 
      ./hardware-configuration.nix
    ];
  hardware.enableAllFirmware = true;
  nixpkgs.config.allowUnfree = true;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl."net.ipv4.conf.all.forwarding" = "1";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.ntp.enable = true;
  services.fwupd.enable = true;

  time.timeZone = "America/New_York";

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  boot.zfs.extraPools = [ "tank" "nvme" ];
  networking.hostId = "abcd1234";
  services.zfs.autoScrub.enable = true;
  services.zfs.trim.enable = true;

  services.nfs.server.enable = true;

  boot.plymouth.enable = true;

  networking.networkmanager.enable = true;
  networking.interfaces.enp5s0.ipv4.addresses = [ {
    address = "192.168.0.3";
    prefixLength = 24;
  } ];

  networking.defaultGateway = "192.168.0.1";
  networking.nameservers = [ "192.168.0.1" ];
  networking.hostName = "server";  

  virtualisation = {
    docker.enable = false;
    podman = {
      enable = true;
      dockerCompat = true;
      dockerSocket.enable = true;
      defaultNetwork.settings.dns_enabled = true;
      extraPackages = [ pkgs.zfs ];
    };
  };

  virtualisation.containers.storage.settings = {  
    storage = {
       driver = "zfs";
       graphroot = "/containers/storage";
       runroot = "/containers/storage";
    };
  }; 

  users.mutableUsers = false;
  users.users.nikola = {
    isNormalUser = true;
    extraGroups = [ "wheel" "podman" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVDmZyOI0fRbQH3Wm23XeuJ9ykbiFy6VBPvmKgTYXdm nikola@laptop" ];
  };

  environment.systemPackages = with pkgs; [
    micro
    git
    wget
    bat
    ripgrep
    neofetch
    iftop
    zsh
    duf
    htop
    tailscale
    lsof
    ncdu
    rsync
    shadow
    arion
    docker-client
  ];

  services.openssh = {
    enable = true;
    passwordAuthentication = false;
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

  services.tailscale.enable = true;
  systemd.services.tailscale-autoconnect = {
    description = "Automatic connection to Tailscale";

    after = [ "network-pre.target" "tailscale.service" ];
    wants = [ "network-pre.target" "tailscale.service" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig.Type = "oneshot";
    script = with pkgs; ''
      sleep 2

      status="$(${tailscale}/bin/tailscale status -json | ${jq}/bin/jq -r .BackendState)"
      if [ $status = "Running" ]; then # if so, then do nothing
        exit 0
      fi

      ${tailscale}/bin/tailscale up -authkey tskey-auth-kwecwu1CNTRL-ahD1vLK13uKhuFCJbxM9mKMiynV7VJxK
    '';
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
    allowedUDPPorts = [ 22 config.services.tailscale.port ];
    trustedInterfaces = [ "tailscale0" ];
  };

  nix.settings.sandbox = true;
  system.stateVersion = "23.05";

}
