{
  pkgs,
  lib,
  inputs,
  config,
  ...
}: let
  cfg = config.HomeManager.impermanence;
in {

  imports = [
    inputs.impermanence.nixosModules.home-manager.impermanence
  ];

  options.HomeManager.impermanence = {
    data.directories = lib.mkOption {
      default = [];
      description = ''
      '';
    };
    data.files = lib.mkOption {
      default = [];
      description = ''
      '';
    };
    cache.directories = lib.mkOption {
      default = [];
      description = ''
      '';
    };
    cache.files = lib.mkOption {
      default = [];
      description = ''
      '';
    };
  };

  config = {
    home.persistence."/persist/home" = {
      directories =
        [
          "Downloads"
          "Music"
          "Pictures"
          "Projects"
          "Documents"
          "Videos"
          ".gnupg"
          ".ssh"
          ".nixops"
          ".local/share/keyrings"
          ".local/share/direnv"
          "nixconf"
        ]
        ++ cfg.directories;
      allowOther = true;
    };
  };
}
