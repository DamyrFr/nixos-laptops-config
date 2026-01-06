{ config, pkgs, lib, username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    programs.zsh = {
      initContent = ''
        # Use compatible TERM for SSH
        export TERM=xterm-256color

        # Host completion configuration
        zstyle ':completion:*:hosts' hosts $hosts
        zstyle ':completion:*:hosts' hosts `cat ~/.cache/xml_hosts_cache`

        # Load extended configuration if it exists
        [[ -f ~/.zshrc_extend ]] && source ~/.zshrc_extend
      '';
    };
  };
}
