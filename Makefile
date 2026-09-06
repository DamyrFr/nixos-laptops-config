check:
	nix flake check

nix-flake-update:
	nix flake update
	nix flake update sofka

nixos-build-ghost:
	sudo nixos-rebuild switch --flake ~/nixos-config#ghost

nixos-build-waays:
	sudo nixos-rebuild switch --flake ~/nixos-config#waays

nixos-clean:
	sudo nix-collect-garbage -d
