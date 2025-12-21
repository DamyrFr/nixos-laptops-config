{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # Use a systemd service to clone/update neovim config
  systemd.user.services.neovim-config-sync = {
    Unit = {
      Description = "Clone or update neovim configuration";
    };
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "sync-neovim-config" ''
        NVIM_DIR="$HOME/.config/nvim"

        if [ ! -d "$NVIM_DIR" ]; then
          echo "Cloning neovim config..."
          ${pkgs.git}/bin/git clone https://github.com/DamyrFr/neovim-config "$NVIM_DIR"
        else
          echo "Neovim config already exists, pulling latest..."
          cd "$NVIM_DIR" && ${pkgs.git}/bin/git pull
        fi
      '';
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.packages = with pkgs; [
    ripgrep
    fd
  ];
}
