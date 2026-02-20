{ config, pkgs, pkgs-unstable, username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = with pkgs; [
      mattermost-desktop
      framework-tool
      framework-tool-tui
      pkgs-unstable.crush
      pkgs-unstable.opencode
      velero
      vcluster
      awscli2
      (google-cloud-sdk.withExtraComponents [google-cloud-sdk.components.gke-gcloud-auth-plugin])
      _1password-gui
      _1password-cli
      openvpn3
    ];
  };
}
