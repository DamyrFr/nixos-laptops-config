{ config, pkgs, ... }:

{
  # Kernel sysctl security hardening
  boot.kernel.sysctl = {
    # Network security
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
    "net.ipv4.conf.all.send_redirects" = 0;
    "net.ipv4.conf.default.send_redirects" = 0;
    "net.ipv4.tcp_syncookies" = 1;
    "net.ipv4.tcp_max_syn_backlog" = 2048;
    "net.ipv4.tcp_synack_retries" = 2;
    "net.ipv4.tcp_syn_retries" = 5;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.icmp_ignore_bogus_error_responses" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.icmp_echo_ignore_all" = 1;
    "net.ipv4.conf.default.log_martians" = 1;

    # Core dumps
    "kernel.core_uses_pid" = 1;
  };

  # AppArmor security framework
  security.apparmor = {
    enable = true;
    packages = [ pkgs.apparmor-profiles ];
  };

  # Enable rtkit for PipeWire
  security.rtkit.enable = true;

  # Polkit (for privilege escalation)
  security.polkit.enable = true;

  # ClamAV antivirus
  services.clamav = {
    daemon.enable = true;
    updater.enable = true;
  };
}
