{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;

    # Load the config cloned by the neovim-config-sync service below.
    # home-manager generates ~/.config/nvim/init.lua itself, so the requires
    # must be injected here or the cloned lua/ modules never load.
    extraLuaConfig = ''
      require('plugins')
      require('settings')
      require('lsp')
    '';
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
    # LSP servers
    pyright                          # pyright (Python)
    yaml-language-server             # yamlls
    vscode-langservers-extracted     # jsonls
    bash-language-server             # bashls
    dockerfile-language-server	     # dockerls
    gopls                            # gopls (Go)
    lua-language-server              # lua_ls
    terraform-ls                     # terraformls
    helm-ls                          # helm_ls
    ansible-language-server          # ansiblels
  ];
}
