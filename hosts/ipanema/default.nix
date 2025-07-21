{ pkgs, ... }:
{
  imports = [
    ./disko.nix
    ../common
    ./homelab
    ./secrets
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd = {
    availableKernelModules = [ "e1000e" ];
    systemd = {
      enable = true;
      network = {
        enable = true;
        networks = {
          "10-all-eth" = {
            matchConfig = {
              Name = "e*";
            }; # Match eth0, enp0s3, etc.
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
    #interfaces.eth0.useDHCP = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [
        22
        2222
      ];
      allowedUDPPorts = [ 53 ];
      interfaces = {
        "adguard0" = {
          allowedTCPPorts = [
            53
            3000
          ];
          allowedUDPPorts = [ 53 ];
        };
      };
      extraCommands = ''
        iptables -A FORWARD -i eth0 -o adguard0 -j ACCEPT
        iptables -A FORWARD -i adguard0 -o eth0 -j ACCEPT

        iptables -t nat -A POSTROUTING -s 10.55.66.22/32 -o eth0 -j MASQUERADE
        iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 3000 -j DNAT --to-destination 10.55.66.22:3000
      '';
    };

  };

  systemd.network = {
    enable = true;
    wait-online.enable = false;

    netdevs = {
      "10-adguard-macvlan" = {
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
      "20-eth0" = {
        matchConfig.Name = "eth0";
        networkConfig = {
          Address = "10.55.66.21/24";
          Gateway = "10.55.66.1";
          MACVLAN = "adguard0";
          DNS = [ "10.55.66.1" ];
          IPv4Forwarding = true;
          IPv6Forwarding = true;
        };
      };

      "30-adguard0" = {
        matchConfig.Name = "adguard0";
        networkConfig = {
          Address = "10.55.66.22/24";
          Gateway = "10.55.66.1";
        };
        linkConfig = {
          RequiredForOnline = false;
        };
      };
    };
  };

  environment.systemPackages = with pkgs; [ powertop ];

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

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  services.resolved = {
    enable = true;
    extraConfig = ''
      DNSStubListener=no
    '';
  };

}
