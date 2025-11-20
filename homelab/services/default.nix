{
  config,
  lib,
  inputs,
  ...
}:
{

  options.homelab.services = {
    enable = lib.mkEnableOption "Settings and services for the homelab";
    serveAssets = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable serving static assets via Caddy";
    };
    defaultInterface = lib.mkOption {
      type = lib.types.str;
      description = "Default network interface for the homelab services";
    };
  };

  config = lib.mkIf config.homelab.services.enable {
    networking.firewall.interfaces."${config.homelab.services.defaultInterface}".allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      acceptTerms = true;
      defaults.email = "admin@martinclaus.dev";
      certs.${config.homelab.baseDomain} = {
        reloadServices = [ "caddy.service" ];
        domain = "${config.homelab.baseDomain}";
        extraDomainNames = [ "*.${config.homelab.baseDomain}" ];
        dnsProvider = "ionos";
        dnsPropagationCheck = true;
        environmentFile = config.homelab.dnsCredentialsFile;
        group = config.services.caddy.group;
      };
    };
    services.caddy = {
      enable = true;

      virtualHosts."assets.${config.homelab.baseDomain}" = lib.mkIf config.homelab.services.serveAssets {
        useACMEHost = config.homelab.baseDomain;
        extraConfig = ''
          root * ${inputs.self}/hosts/${config.homelab.machineName}/assets

          # use "file_server browse" directive to enable directory browsing
          file_server

          encode gzip

          @static {
            path *.css *.js *.png *.jpg *.jpeg *.gif *.ico *.svg *.woff *.woff2 *.ttf *.eot *.pdf *.zip *.webp
          }
          header @static Cache-Control "public, max-age=31536000"
        '';
      };
    };

    virtualisation.podman = {
      dockerCompat = true;
      autoPrune.enable = true;
      defaultNetwork.settings = {
        dns_enabled = true;
      };
    };
    virtualisation.oci-containers = {
      backend = "podman";
    };
  };

  imports = [
    ./homepage
    ./adguardhome
    ./adguardhome-sync
    ./calibre-web
    ./tandoor
    ./loki
  ];
}
