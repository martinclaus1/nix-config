{ config, pkgs, lib, ... }:
let
  forgejo = lib.getExe config.services.forgejo.package;

  createOrUpdateUser = secretFile: extraArgs: ''
    . ${secretFile}
    ${forgejo} admin user create \
      --username "$FORGEJO_USERNAME" \
      --password "$FORGEJO_PASSWORD" \
      --email "$FORGEJO_EMAIL" \
      --must-change-password=false \
      ${extraArgs} \
    || ${forgejo} admin user change-password \
      --username "$FORGEJO_USERNAME" \
      --password "$FORGEJO_PASSWORD"
  '';
in
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
        START_SSH_SERVER = true;
        SSH_PORT = 22;
        SSH_LISTEN_PORT = 2222;
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

  age.secrets.forgejoAdminCredentials.owner = config.services.forgejo.user;
  age.secrets.forgejoUserCredentials.owner = config.services.forgejo.user;

  systemd.services.forgejo-users = {
    description = "Create Forgejo users from secrets";
    after = [ "forgejo.service" ];
    requires = [ "forgejo.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = config.services.forgejo.user;
      WorkingDirectory = config.services.forgejo.stateDir;
    };
    environment = {
      FORGEJO_WORK_DIR = config.services.forgejo.stateDir;
      FORGEJO_CUSTOM = "${config.services.forgejo.stateDir}/custom";
    };
    script = ''
      ${createOrUpdateUser config.age.secrets.forgejoAdminCredentials.path "--admin"}
      ${createOrUpdateUser config.age.secrets.forgejoUserCredentials.path ""}
    '';
  };

  systemd.services.fail2ban = {
    restartTriggers = [
      config.environment.etc."fail2ban/filter.d/forgejo.conf".source
    ];
  };

  # Redirect port 22 to the forgejo SSH listener (2222) without requiring
  # CAP_NET_BIND_SERVICE on the forgejo process
  networking.firewall.extraCommands = ''
    iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222 || true
  '';
}
