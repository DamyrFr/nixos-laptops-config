{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  home.activation.cloneNeovimConfig = config.lib.dag.entryAfter ["writeBoundary"] ''
    NVIM_DIR="$HOME/.config/nvim"

    if [ ! -d "$NVIM_DIR" ]; then
      echo "Cloning neovim config..."
      ${pkgs.git}/bin/git clone https://github.com/DamyrFr/neovim-config "$NVIM_DIR"
    else
      echo "Neovim config already exists, pulling latest..."
      cd "$NVIM_DIR" && ${pkgs.git}/bin/git pull
    fi
  '';

  home.packages = with pkgs; [
    ripgrep
    fd
  ];
}
