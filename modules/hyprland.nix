{ config, pkgs, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Enable XDG portal for screen sharing, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Sound
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Polkit (for authentication prompts)
  security.polkit.enable = true;

  # System packages for Hyprland
  environment.systemPackages = with pkgs; [
    # Wayland essentials
    wayland
    xwayland
    wl-clipboard
    wlroots
    
    # Screenshot and screen recording
    grim
    slurp
    wf-recorder
    
    # Notifications
    libnotify
    
    # File manager
    xfce.thunar
    
    # Image viewer
    imv
    
    # PDF viewer
    zathura
    
    # Network manager applet
    networkmanagerapplet
    
    # Bluetooth
    blueman
    
    # Audio control
    pavucontrol
    
    # Brightness control
    brightnessctl
  ];
}
