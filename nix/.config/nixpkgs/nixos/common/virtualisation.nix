{ config, lib, pkgs, ... }:

{
  boot.kernelModules = [
    "virtio-net" "virtio-blk" "virtio-scsi" "virtio-balloon"
  ];

  # From the QEMU guest, you can connect to this share like \\192.168.122.1\qemu
  # (where 192.168.122.1 is the address of the virb0 interface).
  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    extraConfig = ''
      # This line makes it so that you don't have to make everything 777 in
      # order for the guest to use it.
      acl allow execute always = yes

      security = user
      map to guest = Bad user
      interfaces = virbr0
      bind interfaces only = true

      # don't do printer stuff
      load printers = no
      printing = bsd
      printcap name = /dev/null
      disable spoolss = yes
      show add printer wizard = no

      # performance rice
      server multi channel support = yes
      socket options = SO_RCVBUF=131072 SO_SNDBUF=131072 IPTOS_LOWDELAY TCP_NODELAY IPTOS_THROUGHPUT
      deadtime = 30
      use sendfile = Yes
      write cache size = 262144
      min receivefile size = 16384
      aio read size = 16384
      aio write size = 16384
    '';
    shares = {
      qemu = {
        browseable = "yes";
        available = "yes";
        writable = "yes";
        public = "yes";
        path = "${config.users.users.eqyiel.home}";
      };
    };
  };

  virtualisation.virtualbox.host.enable = true;

  virtualisation.libvirtd.enable = true;

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "virbr0" ];
  };


  # Don't forget to add your user to "libvirtd" group in order to access the
  # QEMU system broker.
  users.users.eqyiel.extraGroups = [ "libvirtd" ];

  environment.systemPackages = with pkgs; [
    virtmanager
  ];
}
