{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    config.allowUnfree = true;
  };

  boot = {
    plymouth.enable = true;
    cleanTmpDir = true;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    kernelPackages = pkgs.linuxPackages_latest;
  };

  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    interfaces.enp0s25.ipv4.addresses = [ {
      address = "192.168.1.222";
      prefixLength = 24;
    } ];
    defaultGateway = "192.168.1.1";
    nameservers = [ "192.168.1.1" ];
    domain = "nikolakuhar.com";
    # proxy.default = "http://user:password@proxy:port/";
    # proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  };

  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  security = {
    polkit.enable = true;
    sudo.wheelNeedsPassword = false;
  };

  users = {
    mutableUsers = false;
    users = {
      nikola = {
        isNormalUser = true;
        shell = pkgs.fish;
        extraGroups = [
          "wheel"
          "networkmnager"
          "libvertd"
        ];
        #openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILVDmZyOI0fRbQH3Wm23XeuJ9ykbiFy6VBPvmKgTYXdm nikola@laptop" ];
        packages = with pkgs; [ ];
      };
    };
  };


  fonts.packages = with pkgs; [
    noto-fonts
    ubuntu_font_family
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    fira
  ];

  virtualisation.libvirtd.enable = true;
  impermanence.enable = true;

  programs = {
    fish.enable = true;
    virt-manager.enable = true;
  };

  services = {
    #flatpack.enable = true;
    netdata.enable = true;
    openssh = {
      enable = true;
      allowSFTP = false;
      challengeResponseAuthentication = false;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
    #tailscale.enable = true;
  };

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-thank 15d";
    };
  };

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

  environment.systemPackages = with pkgs; [
    micro
    wget
    ripgrep
    bat
    neofetch
    iftop
    duf
    lsof
    ncdu
    rsync
    arion
    shadow
    htop
    pkgs.tailscale
    btop
    pciutils
    yt-dlp
    nmap
    git
    angryipscanner
    gnumake
    unzip
    zip
    gnupg
    quickemu
    gtop
    avahi
    ffmpeg-full
    cmake
    go
    gcc
    iotop
    qemu
    virt-manager
    python3
  ];

  system.stateVersion = "24.11";
}
