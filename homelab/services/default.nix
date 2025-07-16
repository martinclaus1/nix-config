{ config, lib, ... }:
{

  options.homelab.services = {
    enable = lib.mkEnableOption "Settings and services for the homelab";
  };

  config = lib.mkIf config.homelab.services.enable {
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    security.acme = {
      acceptTerms = true;
      defaults.email = config.homelab.dnsContactEmail;
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
    };

  };

  imports = [
    ./homepage
  ];

}
