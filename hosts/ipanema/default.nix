{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ./disko.nix
    ../common
    ./homelab
  ];

  networking.hostName = "ipanema";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Remote LUKS unlocking via SSH
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      authorizedKeys = config.sshKeys;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" ];
    };
  };

  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.network.enable = true;
  boot.initrd.availableKernelModules = [ "e1000e" ];

  networking.networkmanager.enable = false;
  systemd.network.enable = true;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;
  systemd.network.wait-online.enable = false;

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  environment.systemPackages = with pkgs; [
    powertop
  ];

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  # Automatic updates for security
  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos\\?submodules=1";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L"
    ];
    dates = "Sat *-*-* 06:00:00";
    randomizedDelaySec = "45min";
    allowReboot = false;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "25.05";

  powerManagement = {
    powertop.enable = true;
  };

  services.auto-aspm = {
    enable = false;
  };
}
