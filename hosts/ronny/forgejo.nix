{ config, pkgs, lib, ... }:
{
  services.postgresql = {
    enable = true;
    ensureDatabases = [ "forgejo" ];
    ensureUsers = [
      { name = "forgejo"; ensureDBOwnership = true; }
    ];
  };

  services.forgejo = {
    enable = true;
    database.type = "postgres";
    database.createDatabase = false;
    database.socket = "/run/postgresql";
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

  services.fail2ban = {
    enable = true;
    jails.forgejo.settings = {
      enabled = true;
      filter = "forgejo";
      backend = "systemd";
      journalmatch = "_SYSTEMD_UNIT=forgejo.service";
      maxretry = 5;
      bantime = 3600;
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
}
