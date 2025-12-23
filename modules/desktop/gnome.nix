{ config, pkgs, username, ... }:

{
  # GNOME-specific system packages
  environment.systemPackages = with pkgs; [
    # GNOME utilities
    gnome-tweaks
    gnome-boxes
    gnomeExtensions.vitals
    gnomeExtensions.user-themes
    gnomeExtensions.blur-my-shell
    gnomeExtensions.tiling-shell
    gnomeExtensions.tailscale-qs
    gnome-shell-extension-pop-shell

    # Theme
    paper-icon-theme
    marble-shell-theme

    # Additional GNOME tools
    wl-clipboard
    lm_sensors
    networkmanagerapplet
    networkmanager-openvpn
    gnome-tweaks

    # GNOME applications
    gnome-pass-search-provider
  ];

  # Remove unwanted GNOME applications (games, etc.)
  environment.gnome.excludePackages = with pkgs; [
    gnome-music
    gnome-logs
    epiphany  # GNOME web browser
    geary     # Email client
    totem     # Video player
    yelp      # Help viewer
    # GNOME Games
    atomix
    hitori
    iagno
    gnome-2048
    tali
    gnome-mahjongg
    gnome-mines
    gnome-nibbles
    gnome-robots
    gnome-sudoku
    gnome-taquin
    gnome-tetravex
    quadrapassel
    swell-foop
    lightsoff
  ];

  # Enable GNOME services
  services.gnome = {
    gnome-keyring.enable = true;
  };

  home-manager.users.${username} = { pkgs, ... }: {
    # Fonts configuration
    home.packages = with pkgs; [
      # Nerd Fonts
      jetbrains-mono
    ];

    # Wallpaper - copy from source
    home.file.".wallpaper.jpg" = {
      source = ./../../img/wallpaper.jpg;
    };

    # Profile picture
    home.file.".face" = {
      source = ./../../img/Moi-2024.jpg;
    };

    # GNOME dconf settings - migrated from Ansible
    dconf.settings = {
      # Desktop interface settings
      "org/gnome/desktop/interface" = {
        clock-show-date = true;
        clock-format = "24h";
        clock-show-seconds = true;
        show-battery-percentage = true;
        gtk-theme = "Marble-gray-light";
        icon-theme = "Paper";
        color-scheme = "prefer-light";
      };

      # Window manager preferences
      "org/gnome/desktop/wm/preferences" = {
        theme = "Adwaita-light";
      };

      # Desktop background
      "org/gnome/desktop/background" = {
        picture-uri = "file:///home/${username}/.wallpaper.jpg";
        picture-uri-dark = "file:///home/${username}/.wallpaper.jpg";
      };

      # GNOME Shell configuration
      "org/gnome/shell" = {
        enabled-extensions = [
          "horizontal-workspaces@gnome-shell-extensions.gcampax.github.com"
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "Vitals@CoreCoding.com"
          "blur-my-shell@aunetx"
          "orge@jmmaranan.com"
          #"tilingshell@ferrarodomenico.com"
          "pop-shell@system76.com"
        ];
        favorite-apps = [
          "kitty.desktop"
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };

      # User theme extension settings
      "org/gnome/shell/extensions/user-theme" = {
        name = "Marble-blue-light";
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

      # Custom keyboard shortcuts
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Launch Kitty";
        command = "kitty";
        binding = "<Super>t";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "Launch Firefox";
        command = "firefox";
        binding = "<Super>f";
      };
    };
  };
}
