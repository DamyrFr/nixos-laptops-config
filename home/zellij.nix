{ config, pkgs, ... }:

{
  programs.zellij = {
    enable = true;
  };

  # Fetch zellij config from GitHub
  home.file.".config/zellij/config.kdl".source = builtins.fetchurl {
    url = "https://raw.githubusercontent.com/DamyrFr/ansible-personal-computer/refs/heads/master/roles/dotfiles/files/config.kdl";
    sha256 = "04p1gs77m73244a9iiqbk7ris1ar3fqvny8kq1ani0xd53apv0nv";
  };
}
