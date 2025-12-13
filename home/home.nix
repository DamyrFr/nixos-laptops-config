{ config, pkgs, username, ... }:

{
  imports = [
#    ./hyprland.nix
    ./zellij.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

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
    kubectl
    kubecolor
    scaleway-cli
    fastfetch
  ];

  # Zsh configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    initContent = ''
      # Setopt configurations
      autoload -Uz vcs_info
      autoload -U colors && colors
      autoload -U select-word-style && select-word-style bash
      autoload -U add-zsh-hook
      autoload -U url-quote-magic
      autoload bashcompinit && bashcompinit
      zle -N self-insert url-quote-magic
      zle -N edit-command-line
      bindkey "^[m" copy-prev-shell-word
      bindkey -e
      setopt multios
      setopt cdablevarS
      setopt prompt_subst
      setopt long_list_jobs
      unsetopt menu_complete
      unsetopt flowcontrol
      setopt auto_menu
      setopt complete_in_word
      setopt always_to_end
      setopt AUTO_CD
      setopt NO_BEEP

      # Functions
      extract () {
        if [ -f $1 ]
        then
          case $1 in
            (*.7z) 7z x $1 ;;
            (*.lzma) unlzma $1 ;;
            (*.rar) unrar x $1 ;;
            (*.tar) tar xvf $1 ;;
            (*.tar.bz2) tar xvjf $1 ;;
            (*.bz2) bunzip2 $1 ;;
            (*.tar.gz) tar xvzf $1 ;;
            (*.gz) gunzip $1 ;;
            (*.tar.xz) tar Jxvf $1 ;;
            (*.xz) xz -d $1 ;;
            (*.tbz2) tar xvjf $1 ;;
            (*.tgz) tar xvzf $1 ;;
            (*.zip) unzip $1 ;;
            (*.Z) uncompress ;;
            (*) echo "don't know how to extract '$1'..." ;;
          esac
        else
          echo "Error: '$1' is not a valid file!"
          exit 0
        fi
      }

      function commit {
        git commit -m "`echo "$*" | sed -e 's/^./\U&\E/g'`"
      }

      function checksec {
        sudo rkhunter --checkall --cronjob
        sudo chkrootkit > /tmp/chkrootkit.log
      }

      # Completions
      source <(kubectl completion zsh)
      eval "$(scw autocomplete script shell=zsh)"
    '';

    sessionVariables = {
      EDITOR = "nvim";
      LC_ALL = "en_US.UTF-8";
      LANG = "en_US.UTF-8";
      LANGUAGE = "en_US.UTF-8";
      GREP_COLORS = "mt=31";
      PASSWORD_STORE_GENERATED_LENGTH = "32";
      AWS_VAULT_BACKEND = "pass";
      AWS_SDK_LOAD_CONFIG = "true";
      GOPATH = "$HOME/go";
    };

    shellAliases = {
      co = "git commit";
      fuck = "sudo !!";
      psg = "ps aux | grep";
      t = "tmux -u";
      p = "ping -c 3";
      s = "ssh";
      d = "docker";
      l = "ls -lra --color=auto";
      v = "nvim";
      c = "curl";
      ex = "extract";
      hs = "history | grep";
      ls = "ls --color=auto";
      ll = "ls --color=auto -lh";
      lll = "ls --color=auto -lh | less";
      weather = "curl http://wttr.in/";
      wth = "curl http://wttr.in/";
      getip = "wget -qO- ifconfig.co";
      pubip = "wget -qO- ifconfig.co";
      python = "python3";
      py = "python3";
      pip = "pip3";
      sw = "sudo su";
      pgps = "gpg2 --clearsign";
      pgpe = "gpg2 --encrypt";
      pgpd = "gpg2 --output tmp_clear --decrypt";
      ip = "ip --color";
      i = "ip --color --brief a";
      gc = "git commit -m";
      ga = "git add";
      gpo = "git push origin";
      gs = "git status";
      gac = "git add . && git commit -a -m";
      dtrash = "docker run -it --rm -v /tmp:/tmp debian:latest /bin/bash";
      ks = "ls";
      xs = "cd";
      av = "aws-vault";
      sl = "ls";
      grep = "grep --color=auto";
      pr = "pass generate -i";
      k = "kubecolor --light-background";
      docker = "podman";
      awsd = "source _awsd";
      tf = "tofu";
      k9ss = "k9s --insecure-skip-tls-verify";
      kb = "kubectl kustomize --load-restrictor LoadRestrictionsNone  ./";
      fs = "flux get all -A --status-selector ready=false";
    };
  };

  # Direnv integration
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

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

  # Kitty config
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrains Mono";
      size = 12;
    };

    settings = {
      # Font configuration
      bold_font = "JetBrains Mono Bold";
      italic_font = "JetBrains Mono Italic";
      bold_italic_font = "JetBrains Mono Bold Italic";
      font_features = "JetBrainsMono-Regular +zero +onum";
      disable_ligatures = "never";

      # Cursor settings
      cursor_shape = "block";
      cursor_blink_interval = 0.5;
      cursor_stop_blinking_after = 15.0;
      cursor = "#000000";
      cursor_text_color = "#FFFFFF";

      # Scrollback
      scrollback_lines = 10000;
      scrollback_pager_history_size = 0;

      # Mouse behavior
      mouse_hide_wait = 3.0;
      url_color = "#0969da";
      url_style = "curly";
      copy_on_select = false;
      strip_trailing_spaces = "never";

      # Performance
      repaint_delay = 10;
      input_delay = 3;
      sync_to_monitor = true;

      # Terminal bell
      enable_audio_bell = false;
      visual_bell_duration = 0.0;
      bell_on_tab = false;

      # Window layout
      remember_window_size = true;
      initial_window_width = 140;
      initial_window_height = 40;
      window_border_width = "0.5pt";
      window_padding_width = 4;
      placement_strategy = "center";

      # Tab bar
      tab_bar_edge = "bottom";
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";

      # GNOME Light theme colors
      foreground = "#2e3436";
      background = "#ffffff";

      color0 = "#171421";
      color1 = "#C01C28";
      color2 = "#26A269";
      color3 = "#A2734C";
      color4 = "#12488B";
      color5 = "#A347BA";
      color6 = "#2AA1B3";
      color7 = "#D0CFCC";
      color8 = "#5E5C64";
      color9 = "#F66151";
      color10 = "#33D17A";
      color11 = "#E9AD0C";
      color12 = "#2A7BDE";
      color13 = "#C061CB";
      color14 = "#33C7DE";
      color15 = "#ffffff";

      # Tab colors
      active_tab_foreground = "#2e3436";
      active_tab_background = "#ffffff";
      inactive_tab_foreground = "#555753";
      inactive_tab_background = "#d3d7cf";
      tab_bar_background = "#d3d7cf";

      # Selection
      selection_foreground = "#ffffff";
      selection_background = "#3465a4";

      # SSH and remote
      term = "xterm-256color";
      allow_remote_control = true;
      allow_hyperlinks = true;

      # Shell integration
      shell_integration = "enabled";
      update_check_interval = 0;

      # Layouts
      enabled_layouts = "tall:bias=50;full_size=1;mirrored=false,stack";

      # Advanced
      shell = "zsh";
      editor = "nvim";
    };

    keybindings = {
      "ctrl+shift+c" = "copy_to_clipboard";
      "ctrl+shift+v" = "paste_from_clipboard";
      "ctrl+shift+s" = "paste_from_selection";
      "shift+insert" = "paste_from_selection";
      "ctrl+shift+up" = "scroll_line_up";
      "ctrl+shift+down" = "scroll_line_down";
      "ctrl+shift+enter" = "new_window";
      "ctrl+shift+w" = "close_window";
      "ctrl+shift+]" = "next_window";
      "ctrl+shift+[" = "previous_window";
      "ctrl+shift+t" = "new_tab";
      "ctrl+shift+q" = "close_tab";
      "ctrl+shift+right" = "next_tab";
      "ctrl+shift+left" = "previous_tab";
      "ctrl+shift+equal" = "change_font_size all +2.0";
      "ctrl+shift+minus" = "change_font_size all -2.0";
      "ctrl+shift+f11" = "toggle_fullscreen";
    };
  };
  fonts.fontconfig.enable = true;
}
