{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.05";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-aspm = {
      url = "github:notthebee/AutoASPM";
      flake = false;
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    secrets = {
      url = "git+ssh://git@github.com/martinclaus1/nix-secrets.git";
      flake = false;
    };
  };

  outputs = { nixpkgs, disko, auto-aspm, ... }@inputs: {
    nixosConfigurations.ipanema = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        disko.nixosModules.disko
        ./hosts/ipanema
        ./modules/auto-aspm
        ./homelab
        inputs.agenix.nixosModules.default
      ];
    };
  };
}
