{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  nixpkgs = {
    config = {
      allowUnfree = true;
      experimental-features = "nix-command flakes";
    };
  };
  
  HomeManager.fish.enable = lib.mkDefault true;
  HomeManager.lf.enable = lib.mkDefault true;
  HomeManager.yazi.enable = lib.mkDefault true;
  HomeManager.nix-extra.enable = lib.mkDefault true;
  HomeManager.btop.enable = lib.mkDefault true;
  HomeManager.nix-direnv.enable = lib.mkDefault true;
  HomeManager.nix.enable = lib.mkDefault true;
  HomeManager.git.enable = lib.mkDefault true;

  programs.home-manager.enable = true;

  programs.bat.enable = true;

  home.packages = with pkgs; [
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
    nil
    file
    killall
    fzf
    lf
    tldr
    thefuck
    eza
    fd
    zoxide
    du-dust
    tree-sitter
    nh
  ];

  home.sessionVariables = {
    FLAKE = "${config.home.homeDirectory}/nixconf";
  };

  myHomeManager.impermanence.data.directories = [
    ".ssh"
  ];
}
