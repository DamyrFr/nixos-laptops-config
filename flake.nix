{
  description = "Damyr NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Not in nixpkgs; upstream ships its own flake + overlay.
    sofka = {
      url = "github:nklmilojevic/sofka";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, sofka }:
  let
    # Makes pkgs.sofka available to every host and to home-manager
    # (useGlobalPkgs = true means it shares the system pkgs).
    overlays = { nixpkgs.overlays = [ sofka.overlays.default ]; };
  in {
    nixosConfigurations = {
      ghost = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          username = "damyr";
          hostname = "ghost";
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          overlays
          ./hosts/ghost/configuration.nix
          ./modules/core
          ./modules/desktop
          ./modules/home

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
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
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          overlays
          ./hosts/waays/configuration.nix
          ./hosts/waays/disko.nix
          disko.nixosModules.disko
          ./modules/core
          ./modules/desktop
          ./modules/home
          ./modules/pro

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              username = "thomas";
            };
            home-manager.users.thomas = import ./modules/home/home.nix;
          }
        ];
      };

      dust = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          username = "damyr";
          hostname = "dust";
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
          overlays
          ./hosts/dust/configuration.nix
          ./hosts/dust/disko.nix
          disko.nixosModules.disko
          ./modules/core
          ./modules/desktop
          ./modules/home

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = {
              username = "damyr";
            };
            home-manager.users.damyr = import ./modules/home/home.nix;
          }
        ];
      };
    };
  };
}
