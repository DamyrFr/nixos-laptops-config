{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System-wide packages (minimal set for root and system operations)
  environment.systemPackages = with pkgs; [
    # Minimal editor for root emergencies
    vim

    # Basic system utilities
    curl
    wget
    rsync
    wirelesstools

    # Network diagnostics (system-level)
    tcpdump
    dnsutils
    traceroute
    net-tools
    tailscale

    # System monitoring
    htop
    strace

    # Security (system-level)
    gnupg
    clamav
    apparmor-profiles
    apparmor-utils

    # Build essentials (system-level)
    git
    gnumake
    gcc
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
        #signingkey = "~/.ssh/id_ed25519.pub";
      };
      gpg.format = "ssh";
      core = {
        editor = "nvim";
        whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        excludesfile = "~/.gitignore";
      };
      commit.gpgsign = false;
      tag.gpgsign = false;
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
      push.autoSetupRemote = true;
    };
  };
}
