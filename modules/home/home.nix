{ config, pkgs, username, ... }:

{
  imports = [
    ./neovim.nix
    ./zellij.nix
#    ../desktop/hyprland.nix
  ];

  home.username = username;
  home.homeDirectory = "/home/${username}";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    fzf
    fastfetch
    nerd-fonts.jetbrains-mono
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
      nixupgrade = "sudo nixos-rebuild switch --flake ~/nixos-config#`hostname`";
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

      env_var.CURRENT_PROJECT = {
        symbol = "🔬 ";
        format = "[$symbol$env_value]($style) ";
        style = "bold purple";
      };
    };
  };

  # Kitty configuration is in modules/kitty.nix
  fonts.fontconfig.enable = true;
}
