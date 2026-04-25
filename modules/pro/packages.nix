{ config, pkgs, pkgs-unstable, username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = with pkgs; [
      mattermost-desktop
      framework-tool
      framework-tool-tui
      velero
      vcluster
      awscli2
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      _1password-gui
      _1password-cli
      openvpn3
      postgresql # Provides psql CLI (server binaries included but no service runs unless enabled)
      # MySQL client already available via mariadb.client in home.nix
    ];
  };
}
