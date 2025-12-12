{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Neovim and dependencies
    neovim

    # LSP servers and tools commonly used with Neovim
    pyright
    nodePackages.typescript-language-server
    nodePackages.yaml-language-server
    lua-language-server
    nil  # Nix LSP
    terraform-ls

    # Clipboard support for Neovim
    xclip
    wl-clipboard

    # Build tools for Neovim plugins
    gcc
    gnumake
    unzip

    # Additional tools for Neovim
    ripgrep  # For telescope
    fd       # For telescope
    tree-sitter
  ];

  # Vim configuration
  # The .vimrc from Ansible should be placed in home directory
  # Vim plugins will be managed by vim-plug as in the Ansible setup

  # Note: To fully replicate the Ansible setup:
  # 1. Clone your neovim config: git clone git@github.com:DamyrFr/neovim-config ~/.config/nvim
  # 2. Copy .vimrc from ansible-personal-computer/roles/dotfiles/files/.vimrc to ~/.vimrc
  # 3. Vim-plug will be installed and plugins will be managed as before
  #
  # For a more declarative approach, consider using home-manager:
  # programs.neovim = {
  #   enable = true;
  #   vimAlias = true;
  #   viAlias = true;
  #   # ... plugin configuration
  # };
}
