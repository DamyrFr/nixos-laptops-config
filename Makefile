check:
	nix flake check

nixos-build:
	sudo nixos-rebuild switch --flake ~/nixos-config#ghost

nixos-clean:
	sudo nix-collect-garbage -d
