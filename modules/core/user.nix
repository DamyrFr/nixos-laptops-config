{ config, pkgs, lib, username, ... }:

{
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "wheel"
      "networkmanager"
      "cdrom"
      "audio"
      "video"
      "plugdev"
      "scanner"
      "libvirtd"  # For virt-manager
    ];
    shell = pkgs.zsh;
  };

  # Enable sudo without password for wheel group
  security.sudo.extraRules = [
    {
      groups = [ "wheel" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Enable zsh system-wide
  programs.zsh.enable = true;
}
