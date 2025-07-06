{ config, pkgs, inputs, ... }: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ../../modules/system/common.nix
    ../common
  ];

  networking.hostName = "ipanema";
  
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.luks.devices."crypted".device = "/dev/disk/by-uuid/YOUR-LUKS-UUID";
  
  # Remote LUKS unlocking via SSH
  boot.initrd.network = {
    enable = true;
    ssh = {
      enable = true;
      port = 2222;
      authorizedKeys = config.sshKeys;
      hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" ];
    };

    # Configure network interface for initrd
    postCommands = ''
      echo 'cryptsetup-askpass' >> /root/.profile
    '';
  };
  
  # Enable networkd in initrd for network setup
  boot.initrd.systemd.network.enable = true;
  boot.initrd.availableKernelModules = [ "e1000e" ];
  
  networking.networkmanager.enable = false;  # Use systemd-networkd for servers
  systemd.network.enable = true;
  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = true;  # Adjust interface name
  
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];  # SSH only by default
  
  
  users = {
    lazycat = {
      shell = pkgs.zsh;
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      group = "lazycat";
      openssh.authorizedKeys.keys = config.sshKeys;  # Use the imported key
    };
  };
  
  groups = {
    lazycat = { 
      gid = 1000;
    };
  };

  programs.zsh.enable = true;
    
  # Disable root login
  users.users.root.openssh.authorizedKeys.keys = [ ];
  
  # System packages for ipanema
  environment.systemPackages = config.commonPackages pkgs;
  
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
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "02:00";
    randomizedDelaySec = "45min";
  };
  
  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  
  system.stateVersion = "24.05";
}