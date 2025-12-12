{ config, pkgs, lib, ... }:

{
  # Enable X11
  services.xserver = {
    enable = true;

    # Keyboard layout
    xkb = {
      layout = "fr";
      variant = "";
    };
  };

  # Enable GNOME Desktop Environment
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # GNOME packages to install
  environment.systemPackages = with pkgs; [
    gnome-tweaks
    gnomeExtensions.vitals
    gnomeExtensions.user-themes
    chromium
    gnome-boxes
    wl-clipboard
    lm_sensors
    # Paper icon theme and Marble shell theme would need to be packaged or installed manually
  ];

  # Exclude unwanted GNOME applications
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-music
    epiphany  # GNOME web browser
    geary     # Email client
    totem     # Video player
    # Games
    gnome-robots
    gnome-mahjongg
    gnome-mines
    gnome-nibbles
    gnome-taquin
    gnome-tetravex
    aisleriot  # Solitaire
    atomix
    hitori
    iagno
    quadrapassel
    swell-foop
    tali
  ];

  # Install fonts
  fonts.packages = with pkgs; [
    nerd-fonts.hack
    nerd-fonts.symbols-only
    nerd-fonts.jetbrains-mono
  ];

  # GNOME dconf settings (per-user configuration)
  # These should be set using home-manager for better declarative management
  # or manually using dconf after first login
  programs.dconf.enable = true;

  # Note: For full dconf configuration, consider using home-manager
  # Here's an example of what the home-manager configuration would look like:
  #
  home-manager.users.damyr = {
    dconf.settings = {
      "org/gnome/desktop/background" = {
        picture-uri = "file:///home/damyr/.wallpaper.jpg";
      };
      "org/gnome/desktop/interface" = {
        clock-show-date = true;
        clock-format = "24h";
        clock-show-seconds = true;
        show-battery-percentage = true;
        gtk-theme = "Adwaita-dark";
        color-scheme = "prefer-dark";
      };
      "org/gnome/desktop/wm/preferences" = {
        theme = "Adwaita-dark";
      };
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
      "org/gnome/desktop/applications/terminal" = {
        exec = "kitty";
      };
      "org/gnome/terminal/legacy" = {
        menu-accelerator-enabled = true;
      };
      "org/gnome/nautilus/preferences" = {
        search-filter-time-type = "last_modified";
        default-folder-viewer = "icon-view";
      };
    };
  };

  # Enable CUPS for printing
  services.printing.enable = true;

  # PipeWire for audio
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}
