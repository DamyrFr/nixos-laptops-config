{ config, pkgs, username, ... }:

{
  imports = [
    ./hyprland.nix
  ];


  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;

  # Install neovim
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
    fzf
    nerd-fonts.jetbrains-mono
  ];

	# Starship config

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    
    settings = {
      add_newline = true;
      
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };

      git_branch = {
        symbol = "🌱 ";
        truncation_length = 20;
        truncation_symbol = "…";
      };

      git_status = {
        conflicted = "🏳";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "🤷";
        stashed = "📦";
        modified = "📝";
        staged = "[++($count)](green)";
        renamed = "👅";
        deleted = "🗑";
      };

      nodejs = {
        symbol = " ";
        disabled = false;
      };

      python = {
        symbol = " ";
        disabled = false;
      };

      rust = {
        symbol = " ";
        disabled = false;
      };

      package = {
        disabled = true;
      };
    };
  };

	#Kitty config

  programs.kitty = {
    enable = true;
    
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    settings = {
      # Window
      window_padding_width = 10;
      confirm_os_window_close = 0;
      
      # Colors (adjust to your preference)
      background = "#1e1e2e";
      foreground = "#cdd6f4";
      
      # Cursor
      cursor = "#f5e0dc";
      cursor_text_color = "#1e1e2e";
      
      # Selection
      selection_background = "#f5e0dc";
      selection_foreground = "#1e1e2e";
      
      # URLs
      url_color = "#f5e0dc";
      url_style = "curly";
      
      # Tabs
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      
      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = "yes";
      
      # Bell
      enable_audio_bell = "no";
      visual_bell_duration = "0.0";
      
      # Advanced
      shell = "zsh";
      editor = "nvim";
    };

    # Keybindings
    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
    };
  };
  fonts.fontconfig.enable = true;
}
