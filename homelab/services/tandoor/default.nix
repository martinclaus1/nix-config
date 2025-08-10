{ config, lib, ... }:
let
  cfg = config.homelab.services.tandoor;
  homelab = config.homelab;
  service = "tandoor";
in {
  options.homelab.services.${service} = {
    enable =
      lib.mkEnableOption { description = "Enable Tandoor Recipe Manager"; };

    url = lib.mkOption {
      type = lib.types.str;
      default = "recipes.${homelab.baseDomain}";
      description = "URL for accessing Tandoor";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for Tandoor application";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address for Tandoor to bind to";
    };

    secretKeyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to file containing the Django secret key";
    };

    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Tandoor Recipes";
    };

    homepage.description = lib.mkOption {
      type = lib.types.str;
      default =
        "Recipe manager for collecting, organizing and sharing your culinary creations";
    };

    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "tandoor-recipes.svg";
    };

    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Content";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable PostgreSQL service
    services.postgresql = {
      enable = true;
      ensureDatabases = [ "tandoor_recipes" ];
      authentication = ''
        local tandoor_recipes tandoor_recipes peer
      '';
      ensureUsers = [{
        name = "tandoor_recipes";
        ensureDBOwnership = true;
      }];
    };

    services.tandoor-recipes = {
      enable = true;
      group = homelab.group;
      address = cfg.address;
      port = cfg.port;
      database.createLocally = false;
      extraConfig = {
        SECRET_KEY_FILE = cfg.secretKeyFile;
        TZ = homelab.timeZone;
        DB_ENGINE = "django.db.backends.postgresql";
        POSTGRES_HOST = "/run/postgresql";
        POSTGRES_DB = "tandoor_recipes";
        POSTGRES_USER = "tandoor_recipes";
        ALLOWED_HOSTS = cfg.url;
      };
    };

    # Caddy reverse proxy configuration
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://${cfg.address}:${toString cfg.port}
      '';
    };
  };
}
