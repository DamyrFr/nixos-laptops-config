{ config, pkgs, hostname, ... }:

{
  # Hostname
  networking.hostName = "${hostname}";

  # Timezone
  time.timeZone = "Europe/Paris";

  # DNS Configuration
  # Use systemd-resolved with custom DNS servers
  networking.networkmanager.enable = true;

  # Custom DNS servers (via systemd-resolved)
  networking.nameservers = [ "9.9.9.11" "1.1.1.1" ];

  # Locale settings
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Console keymap
  console.keyMap = "fr";
}
