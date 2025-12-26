{ config, pkgs, pkgs-unstable, username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = with pkgs; [
      mattermost-desktop
      framework-tool
      framework-tool-tui
      pkgs-unstable.crush
      velero
      vcluster
      awscli2
      google-cloud-sdk
    ];
  };
}
