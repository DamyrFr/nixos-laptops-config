{ config, pkgs, ... }:

let
  # Per-remote Git identities, selected automatically via
  # includeIf "hasconfig:remote.*.url:..." based on a repo's remote URLs.
  #
  # IMPORTANT: the default identity must be provided via an unconditional
  # `[include]`, NOT via an inline `[user]` section. The NixOS programs.git
  # module renders sections alphabetically, so an inline `[user]` block would
  # always be emitted AFTER the `[includeIf]` blocks and, since Git applies
  # config top-to-bottom with last-value-wins, it would override the matched
  # per-remote identity. `[include]` sorts before `[includeIf]`, so the
  # conditional identities correctly take precedence.
  identityDamyR = pkgs.writeText "git-identity-damyr" ''
    [user]
    	name = DamyR
    	email = thomas@anvir.fr
  '';
  identityTw = pkgs.writeText "git-identity-tw" ''
    [user]
    	name = tw
    	email = tg@waays.fr
  '';
in
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
    pwgen

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
    openssl
    age

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
  programs.chromium.enable = true;

  # Configure Git globally
  programs.git = {
    enable = true;
    config = {
      # Default identity (personal machines: DamyR). Provided via an
      # unconditional `[include]` so it sits BEFORE the `[includeIf]` blocks in
      # the generated (alphabetically-ordered) gitconfig, letting the per-remote
      # rules below override it. On the pro machine this default is overridden
      # to tw via modules/pro/git.nix.
      include.path = "${identityDamyR}";

      # github.com -> DamyR (https, scp-style ssh, and ssh:// remotes).
      # NB: scp-style URLs (git@host:path) require the ":*/**" form; a bare
      # ":**" does not match how Git evaluates hasconfig URLs.
      "includeIf \"hasconfig:remote.*.url:https://github.com/**\"".path = "${identityDamyR}";
      "includeIf \"hasconfig:remote.*.url:git@github.com:*/**\"".path = "${identityDamyR}";
      "includeIf \"hasconfig:remote.*.url:ssh://git@github.com/**\"".path = "${identityDamyR}";

      # git.waays.fr -> tw (https, scp-style ssh, and ssh:// remotes)
      "includeIf \"hasconfig:remote.*.url:https://git.waays.fr/**\"".path = "${identityTw}";
      "includeIf \"hasconfig:remote.*.url:git@git.waays.fr:*/**\"".path = "${identityTw}";
      "includeIf \"hasconfig:remote.*.url:ssh://git@git.waays.fr/**\"".path = "${identityTw}";
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
