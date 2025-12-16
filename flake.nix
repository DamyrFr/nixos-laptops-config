{
  description = "Damyr NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosConfigurations = {
      ghost = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { 
          username = "damyr";
          hostname = "ghost";
        };
        modules = [
          ./hosts/ghost/configuration.nix
          ./modules/user.nix
          ./modules/neovim.nix
          ./modules/packages.nix
          ./modules/security.nix
          ./modules/services.nix
          ./modules/system.nix
          ./modules/kitty.nix
          ./modules/gnome.nix

          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { 
              username = "damyr"; 
            };
            home-manager.users.damyr = import ./home/home.nix;
          }
        ];
      };
      
      #waays = nixpkgs.lib.nixosSystem {
      #  system = "x86_64-linux";
      #  modules = [
      #    ./hosts/waays/configuration.nix
      #  ];
      #};
    };
  };
}
