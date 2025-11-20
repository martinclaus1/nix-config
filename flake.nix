{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs =
    {
      nixpkgs,
      disko,
      ...
    }@inputs:
    {
      nixosConfigurations.ipanema = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          ./hosts/ipanema
          ./homelab
          ./users/lazycat
          inputs.agenix.nixosModules.default
        ];
      };

      nixosConfigurations.margarita = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          disko.nixosModules.disko
          ./hosts/margarita
          ./homelab
          ./users/lazycat
          inputs.agenix.nixosModules.default
        ];
      };
    };
}
