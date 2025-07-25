{ pkgs, ... }:
let
  interface = "eth0";
in
{
  imports = [
    ./disko.nix
    ../common
    ./homelab
    ./secrets
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
  boot.kernelParams = [ "net.ifnames=0" ];

  boot.initrd = {
    availableKernelModules = [ "e1000e" ];
    systemd = {
      enable = true;
      network = {
        enable = true;
        networks = {
          "10-all-${interface}" = {
            matchConfig = {
              Name = "${interface}";
            };
            networkConfig = {
              Address = "10.55.66.21/24";
              Gateway = "10.55.66.1";
              DNS = [ "10.55.66.1" ];
            };
          };
        };
      };
    };
    network = {
      enable = true;
      flushBeforeStage2 = true;

      ssh = {
        enable = true;
        port = 2222;
        hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" ];
      };
    };
  };

  networking = {
    hostName = "ipanema";
    networkmanager.enable = false;
    useDHCP = false;
    firewall = {
      enable = true;
      checkReversePath = false;
      interfaces = {
        "${interface}" = {
          allowedTCPPorts = [
            22
            2222
          ];
        };
        "adguard0" = {
          allowedTCPPorts = [ 53 ];
          allowedUDPPorts = [ 53 ];
        };
      };
      extraCommands = '''';
    };

  };

  systemd.network = {
    enable = true;
    wait-online.enable = true;

    netdevs = {
      "00-adguard-macvlan" = {
        netdevConfig = {
          Kind = "macvlan";
          Name = "adguard0";
        };
        macvlanConfig = {
          Mode = "bridge";
        };
      };
    };

    networks = {
      "${interface}" = {
        matchConfig.Name = "${interface}";
        networkConfig = {
          Address = "10.55.66.21/24";
          Gateway = "10.55.66.1";
          MACVLAN = "adguard0";
          DNS = [ "10.55.66.1" ];
        };
        linkConfig = {
          RequiredForOnline = "yes";
        };
      };

      "00-adguard0" = {
        matchConfig.Name = "adguard0";
        networkConfig = {
          Address = "10.55.66.22/24";
        };
        linkConfig = {
          RequiredForOnline = "no";
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [
    powertop
    tcpdump
    ncdu
    dig
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

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "25.05";

  powerManagement = {
    powertop.enable = true;
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
      DNSStubListener=no
    '';
  };

}
