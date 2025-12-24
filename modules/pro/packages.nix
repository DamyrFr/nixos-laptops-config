{ config, pkgs, username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    home.packages = with pkgs; [
      mattermost-desktop
      framework-tool
      framework-tool-tui
      crush
      velero
      vcluster
      awscli2
      google-cloud-sdk
    ];
  };
}
