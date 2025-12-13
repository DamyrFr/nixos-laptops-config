{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
  };

  # Fetch zellij config directly from GitHub
  home.file.".config/zellij/config.kdl".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/DamyrFr/ansible-personal-computer/refs/heads/master/roles/dotfiles/files/config.kdl";
    sha256 = "1s9bh2n56wsarxbwb8m7hh93fm5krzy670z4wasz70m3k250gmpk";
  };
}
