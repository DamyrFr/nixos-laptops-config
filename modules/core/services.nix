{ config, pkgs, username, ... }:

{
  # Enable and configure libvirtd for virt-manager
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      # OVMF images are now available by default, no need to configure
    };
  };

  # Enable Podman (container runtime)
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;  # Create docker alias
    defaultNetwork.settings.dns_enabled = true;
  };

  # VirtualBox guest additions (only enable on VMs, not physical machines)
  # Set virtualisation.virtualbox.guest.enable = true in host config if needed

  # Enable OpenVPN
  services.openvpn.servers = {
    # Configure your VPN connections here if needed
  };

  # Enable systemd-resolved for DNS
  services.resolved = {
    enable = true;
    dnssec = "allow-downgrade";
    # DNS servers are configured in system.nix via networking.nameservers
  };

  # Enable PCSC for smart card support (GPG)
  services.pcscd.enable = true;
  hardware.gpgSmartcards.enable = true;

  # Enable Tailscale
  services.tailscale.enable = true;

  # Enable automatic system updates
  system.autoUpgrade = {
    enable = true;
    flake = "/home/${username}/nixos-config";
    flags = [
      "--update-input" "nixpkgs"
      "--commit-lock-file"
    ];
    dates = "daily";
    randomizedDelaySec = "45min";
    allowReboot = false;
  };

  # Automatic garbage collection
  nix.gc = {
    dates = "weekly";
  };

  # Keep only the last 5 generations
  boot.loader.systemd-boot.configurationLimit = 5;
}
