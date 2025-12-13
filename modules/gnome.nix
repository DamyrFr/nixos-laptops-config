{ config, pkgs, ... }:

{
  home-manager.users.damyr = { pkgs, ... }: {
    # GNOME dconf settings - migrated from Ansible
    dconf.settings = {
      # Desktop interface settings
      "org/gnome/desktop/interface" = {
        clock-show-date = true;
        clock-format = "24h";
        clock-show-seconds = true;
        show-battery-percentage = true;
        gtk-theme = "Adwaita-dark";
        icon-theme = "Paper";
        color-scheme = "prefer-dark";
      };

      # Window manager preferences
      "org/gnome/desktop/wm/preferences" = {
        theme = "Adwaita-dark";
      };

      # Desktop background
      "org/gnome/desktop/background" = {
        picture-uri = "file:///home/damyr/.wallpaper.jpg";
        picture-uri-dark = "file:///home/damyr/.wallpaper.jpg";
      };

      # GNOME Shell configuration
      "org/gnome/shell" = {
        enabled-extensions = [
          "horizontal-workspaces@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "Vitals@CoreCoding.com"
        ];
        favorite-apps = [
          "kitty.desktop"
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };

      # User theme extension settings
      "org/gnome/shell/extensions/user-theme" = {
        name = "";
      };

      # Default terminal application
      "org/gnome/desktop/applications/terminal" = {
        exec = "kitty";
      };

      # GNOME Terminal settings
      "org/gnome/terminal/legacy" = {
        menu-accelerator-enabled = true;
      };

      # Nautilus (Files) preferences
      "org/gnome/nautilus/preferences" = {
        search-filter-time-type = "last_modified";
        default-folder-viewer = "icon-view";
      };
    };
  };
}
