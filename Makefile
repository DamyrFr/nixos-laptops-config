check:
	nix flake check

nixos-build-ghost:
	sudo nixos-rebuild switch --flake ~/nixos-config#ghost

nixos-build-waays:
	sudo nixos-rebuild switch --flake ~/nixos-config#waays

nixos-clean:
	sudo nix-collect-garbage -d
