{ config, pkgs, ... }:

{
  home-manager.users.damyr = { pkgs, ... }: {
    home.stateVersion = "25.11";
  };
}
