{inputs}: let
  lib = (import ./default.nix) {inherit inputs;};
  outputs = inputs.self.outputs;
in rec {
  pkgsFor = sys: inputs.nixpkgs.legacyPackages.${sys};

  mkSystem = config:
    inputs.nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs outputs myLib;
      };
      modules = [
        config
        outputs.nixosModules.default
      ];
    };

  mkHome = sys: config:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsFor sys;
      extraSpecialArgs = {
        inherit inputs myLib outputs;
      };
      modules = [
        config
        outputs.homeManagerModules.default
      ];
  };
}
