{
  description = "NixOS flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-index-database = {
      url = "github:Mic92/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-colors.url = "github:misterio77/nix-colors";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs = {self, nixpkgs, home-manager,...}@inputs: 
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in {
    nixosConfigurations.server = {
        laptop = mkSystem ./hosts/laptop/configuration.nix;
        server = mkSystem ./hosts/server/configuration.nix;
    };
    homeConfigurations = {
        "nikola@laptop" = mkHome "x86_64-linux" ./hosts/laptop/home.nix;
        "nikola@server" = mkHome "x86_64-linux" ./hosts/server/home.nix;
    };
  };
}
