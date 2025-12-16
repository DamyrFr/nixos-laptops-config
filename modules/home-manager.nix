{ config, pkgs, username, ... }:

{
  home-manager.users.${username} = { pkgs, ... }: {
    home.stateVersion = "25.11";
  };
}
