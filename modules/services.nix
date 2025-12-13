{ config, pkgs, ... }:

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

  # VirtualBox guest additions (if needed)
  virtualisation.virtualbox.guest.enable = true;

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
}
