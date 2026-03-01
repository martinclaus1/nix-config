{ config, pkgs, lib, ... }:
{
  imports = [
    ./disko.nix
    ../common
    ./ssh.nix
    ./forgejo.nix
  ];

  boot.initrd.availableKernelModules = [ "virtio_pci" "virtio_scsi" "ahci" "sd_mod" ];

  boot.loader.grub.enable = true;
  boot.loader.grub.devices = lib.mkForce [ "/dev/sda" ];

  networking = {
    hostName = "ronny";
    useDHCP = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 80 443 ];
    };
  };

  # Fix ownership of the agenix identity key placed by nixos-anywhere (root-owned)
  systemd.tmpfiles.rules = [
    "d /home/lazycat/.ssh 0700 lazycat lazycat -"
    "z /home/lazycat/.ssh/id_ed25519 0600 lazycat lazycat -"
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "25.05";
}
