{ pkgs, inputs, username, ... }:

{
  # Niri compositor
  programs.niri.enable = true;

  # Noctalia prerequisites
  hardware.bluetooth.enable = true;
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # Noctalia package (from flake input)
  environment.systemPackages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  home-manager.users.${username} = { pkgs, ... }: {
    imports = [ inputs.noctalia.homeModules.default ];

    # Noctalia shell
    programs.noctalia-shell.enable = true;

    # Niri compositor settings
    programs.niri.settings = {
      # Spawn noctalia on startup
      spawn-at-startup = [
        { command = [ "noctalia-shell" ]; }
      ];

      # Rounded corners + allow window activation from noctalia
      window-rule = [
        {
          geometry-corner-radius = {
            top-left = 20.0;
            top-right = 20.0;
            bottom-left = 20.0;
            bottom-right = 20.0;
          };
          clip-to-geometry = true;
        }
      ];

      debug = {
        honor-xdg-activation-with-invalid-serial = true;
      };

      # Wallpaper / overview layer rules (Option 2: stationary wallpaper)
      # Set programs.noctalia-shell.settings to toggle overview wallpaper off if using this
      layer-rule = [
        {
          match.namespace = "^noctalia-wallpaper*";
          place-within-backdrop = true;
        }
      ];

      layout = {
        background-color = "transparent";
      };

      overview = {
        workspace-shadow.off = {};
      };
    };
  };
}
