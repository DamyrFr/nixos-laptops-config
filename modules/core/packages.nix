{ config, pkgs, ... }:

let
  # Override os-service-types to add missing typing-extensions dependency
  python3Packages = pkgs.python311Packages.override {
    overrides = self: super: {
      os-service-types = super.os-service-types.overridePythonAttrs (old: {
        propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [ self.typing-extensions ];
      });
    };
  };
in
{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [
    # Editors
    vim
    neovim

    # Shell tools
    zsh
    tmux
    starship
    zellij
    direnv
    fzf

    # DevOps
    kubectl
    kubecolor
    k9s
    scaleway-cli

    # Network tools
    curl
    wget
    rsync
    tcpdump
    dnsutils
    traceroute
    nmap
    net-tools
    ipcalc
    fping
    openvpn
    testssl

    # System utilities
    htop
    ncdu
    strace
    neofetch
    tree

    # Search and text processing
    ripgrep
    ack
    jq
    silver-searcher

    # Development tools
    git
    pre-commit
    gnumake
    gcc
    automake
    autoconf

    # Programming languages
    python3
    python311Packages.pip
    nodejs
    nodePackages.npm
    nodePackages.yarn
    ruby
    go

    # Container tools
    podman
    podman-compose
    buildah

    # Cloud and infrastructure tools
    kubectl
    kubecolor
    terraform
    terraform-ls
    terragrunt
    packer
    google-cloud-sdk

    # Kubernetes/DevOps
    helm
    opentofu

    # Security tools
    gnupg
    pass
    clamav
    apparmor-profiles
    apparmor-utils

    # Virtualization
    virt-manager
    vagrant

    # Multimedia
    vlc
    spotify

    # Terminal emulator
    kitty

    # Latex
    texlive.combined.scheme-full
    texlivePackages.latexmk

    # Task management
    taskwarrior2

    # OpenStack client
    python3Packages.python-openstackclient

    # Other utilities
    cups
    tfsec
    terraform-docs

    # Build tools and compilers
    cmake
    pkg-config

    # Python development
    python311
    python311Packages.virtualenv

    # Ruby development
    bundler

    # AI tools
    claude-code
  ];

  # Enable GPG agent
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Enable direnv
  programs.direnv.enable = true;

  # Firefox
  programs.firefox.enable = true;

  # Configure Git globally
  programs.git = {
    enable = true;
    config = {
      user = {
        name = "Thomas";
        email = "thomas@anvir.fr";
        signingkey = "~/.ssh/id_ed25519.pub";
      };
      gpg.format = "ssh";
      core = {
        editor = "nvim";
        whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        excludesfile = "~/.gitignore";
      };
      commit.gpgsign = true;
      tag.gpgsign = true;
      web.browser = "firefox";
      color = {
        ui = "auto";
        branch = {
          current = "yellow bold";
          local = "green bold";
          remote = "cyan bold";
        };
        diff = {
          meta = "yellow bold";
          frag = "magenta bold";
          old = "red bold";
          new = "green bold";
          whitespace = "red reverse";
        };
        status = {
          added = "green bold";
          changed = "yellow bold";
          untracked = "red bold";
        };
      };
      diff = {
        tool = "vimdiff";
        colorMoved = "zebra";
      };
      alias = {
        lg = "log --all --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        am = "commit --amend --no-edit";
      };
      pull.rebase = true;
      fetch.prune = true;
    };
  };
}
