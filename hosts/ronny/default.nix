{ config, pkgs, lib, ... }:
{
  imports = [
    ./disko.nix
    ../common
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

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      KbdInteractiveAuthentication = false;
    };
  };

  programs.ssh.extraConfig = ''
    Host github.com
      IdentityFile /etc/ssh/ssh_host_ed25519_key
  '';

  # Forgejo git forge
  services.forgejo = {
    enable = true;
    database.type = "sqlite3";
    settings = {
      server = {
        DOMAIN = "git.martinclaus.dev";
        ROOT_URL = "https://git.martinclaus.dev/";
        HTTP_ADDR = "127.0.0.1";
        HTTP_PORT = 3000;
      };
      service = {
        DISABLE_REGISTRATION = true;
      };
    };
  };

  # ACME certificate via IONOS DNS challenge
  security.acme = {
    acceptTerms = true;
    defaults.email = "admin@martinclaus.dev";
    certs."git.martinclaus.dev" = {
      dnsProvider = "ionos";
      dnsPropagationCheck = true;
      environmentFile = config.age.secrets.dnsApiCredentials.path;
      group = config.services.caddy.group;
      reloadServices = [ "caddy.service" ];
    };
  };

  # Caddy reverse proxy
  services.caddy = {
    enable = true;
    virtualHosts."git.martinclaus.dev" = {
      useACMEHost = "git.martinclaus.dev";
      extraConfig = ''
        reverse_proxy localhost:3000
      '';
    };
  };

  # fail2ban for SSH and Forgejo
  services.fail2ban = {
    enable = true;
    jails = {
      sshd = {
        settings = {
          enabled = true;
          filter = "sshd";
          maxretry = 5;
        };
      };
      forgejo = {
        settings = {
          enabled = true;
          filter = "forgejo";
          backend = "systemd";
          journalmatch = "_SYSTEMD_UNIT=forgejo.service";
          maxretry = 5;
          bantime = 3600;
        };
      };
    };
  };

  environment.etc."fail2ban/filter.d/forgejo.conf".text = ''
    [Definition]
    failregex = Failed authentication attempt for .* from <HOST>:\d+:
    ignoreregex =
  '';

  systemd.services.fail2ban = {
    restartTriggers = [
      config.environment.etc."fail2ban/filter.d/forgejo.conf".source
    ];
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
