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
}
