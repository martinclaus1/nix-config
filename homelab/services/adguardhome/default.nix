{ config, lib, ... }:
let
  cfg = config.homelab.services.adguardhome;
  homelab = config.homelab;
in
{
  options.homelab.services.adguardhome = {
    enable = lib.mkEnableOption { description = "Enable AdGuard Home"; };
    dnsBindHost = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The host to bind the AdGuard Home DNS service to";
    };
    hashedPassword = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The hashed password for the AdGuard Home user";
    };
  };
  config = lib.mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      settings = {
        dns = {
          bind_hosts = [ cfg.dnsBindHost ];
        };
        users = [
          {
            name = "lavendel";
            password = "placeholder";
          }
        ];
      };
    };

    systemd.services.adguardhome = {
      serviceConfig = {
        LoadCredential = [ "password:${cfg.hashedPassword}" ];
      };
      preStart = ''
        if [ -f "$CREDENTIALS_DIRECTORY/password" ]; then
          password_hash=$(cat "$CREDENTIALS_DIRECTORY/password")
          sed -i "s/placeholder/$password_hash/g" \
            /var/lib/AdGuardHome/AdGuardHome.yaml
        fi
      '';
    };

    services.caddy.virtualHosts."adguard.${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${config.services.adguardhome.host}:${toString config.services.adguardhome.port}
      '';
    };
  };

}
