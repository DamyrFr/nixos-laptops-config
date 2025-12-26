{ config, pkgs, lib, username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    programs.zsh = {
      initExtra = ''
        # Host completion configuration
        zstyle ':completion:*:hosts' hosts $hosts
        zstyle ':completion:*:hosts' hosts `cat ~/.ssh_hosts_list`

        # Load extended configuration if it exists
        [[ -f ~/.zshrc_extend ]] && source ~/.zshrc_extend
      '';
    };
  };
}
