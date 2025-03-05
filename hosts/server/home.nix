
{
  inputs,
  outputs,
  pkgs,
  lib,
  ...
}: {
  imports = [outputs.homeManagerModules.default];

  HomeManager = {
    bundles.general.enable = true;
  };

  home = {
    username = "nikola";
    stateVersion = "24.11";

    packages = with pkgs; [];
  };
}
