{ config, pkgs, username, ... }:

{
  home.file.".local/bin/extract_servers.sh" = {
    text = ''
      #!/bin/sh
      find /home/${username}/Workspaces/aa/bcfg2/Metadata/ -name "clients.xml" -type f 2>/dev/null | while read file; do
        ${pkgs.yq}/bin/xq -r '
          .Clients.Client | 
          (if type == "array" then .[] else . end) | 
          .["@name"], (.Alias | if . then (if type == "array" then .[].["@name"] else .["@name"] end) else empty end)
        ' "$file" 2>/dev/null
      done | ${pkgs.coreutils}/bin/grep -v null | ${pkgs.coreutils}/bin/sort -u
    '';
    executable = true;
  };

  programs.zsh = {
    initExtra = ''
      _get_xml_hosts() {
        local cache_file="$HOME/.cache/xml_hosts_cache"
        mkdir -p "$(dirname "$cache_file")"
        
        if [[ ! -f "$cache_file" ]] || [[ $(find "$cache_file" -mmin +60 2>/dev/null) ]]; then
          ~/.local/bin/extract_servers.sh > "$cache_file" 2>/dev/null
        fi
        
        cat "$cache_file" 2>/dev/null
      }

      _ssh_hosts_from_xml() {
        local -a hosts
        hosts=(''${(f)"$(_get_xml_hosts)"})
        _describe 'xml-hosts' hosts
      }

      compdef _ssh_hosts_from_xml ssh scp sftp
    '';
  };
}
