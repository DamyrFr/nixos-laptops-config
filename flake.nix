{
  description = "Damyr NixOS configuration";

  nixConfig = {
    extra-substituters = [ "https://noctalia.cachix.org" ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
    ];
  };

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
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, disko, noctalia, ... } @ inputs: {
    nixosConfigurations = {
      ghost = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          username = "damyr";
          hostname = "ghost";
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
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
          inherit inputs;
          username = "thomas";
          hostname = "lapwar";
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
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
          inherit inputs;
          username = "damyr";
          hostname = "dust";
          pkgs-unstable = import nixpkgs-unstable {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
        };
        modules = [
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
