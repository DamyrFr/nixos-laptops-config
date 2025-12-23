{
  description = "Damyr NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, disko }: {
    nixosConfigurations = {
      ghost = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          username = "damyr";
          hostname = "ghost";
        };
        modules = [
          ./hosts/ghost/configuration.nix
          ./modules/core
          ./modules/desktop
          ./modules/home

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              username = "damyr";
            };
            home-manager.users.damyr = import ./modules/home/home.nix;
          }
        ];
      };
      
      lapwar = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          username = "thomas";
          hostname = "lapwar";
        };
        modules = [
          ./hosts/waays/configuration.nix
          ./hosts/waays/disko.nix
          disko.nixosModules.disko
          ./modules/core
          ./modules/desktop/hyprland.nix
          ./modules/home
          ./modules/pro

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = {
              username = "thomas";
            };
            home-manager.users.thomas = import ./modules/home/home.nix;
          }
        ];
      };
    };
  };
}
