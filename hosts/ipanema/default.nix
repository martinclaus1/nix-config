{
  lib,
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

  # Enable networkd in initrd for network setup
  boot.initrd.systemd.enable = true;
  boot.initrd.systemd.network.enable = true;
  boot.initrd.availableKernelModules = [ "e1000e" ];

  networking.networkmanager.enable = false; # Use systemd-networkd for servers
  systemd.network.enable = true;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true; # Adjust interface name

  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ]; # SSH only by default

  users.users = {
    lazycat = {
      shell = pkgs.zsh;
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      group = "lazycat";
      openssh.authorizedKeys.keys = config.sshKeys; # Use the imported key
    };
  };

  users.groups = {
    lazycat = {
      gid = 1000;
    };
  };

  programs.zsh.enable = true;

  # Disable root login
  users.users.root.openssh.authorizedKeys.keys = [ ];

  # Machine-specific packages for ipanema
  environment.systemPackages = with pkgs; [
    powertop
  ];

  # System packages for ipanema are defined in common/default.nix

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
    allowReboot = true;
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "24.05";

  powerManagement = {
    powertop.enable = true;
  };

  services.auto-aspm = {
    enable = false;
  };

  homelab = {
    enable = true;
    dnsCredentialsFile = config.age.secrets.dnsApiCredentials.path;
    baseDomain = "aperol.martinclaus.dev";
    services = {
      enable = true;
      homepage = {
        enable = true;
      };
    };
  };
}
