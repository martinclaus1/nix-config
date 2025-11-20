{ config, lib, ... }:
let
  cfg = config.homelab.services.loki;
  homelab = config.homelab;
  service = "loki";
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption { description = "Enable Loki log aggregation"; };

    url = lib.mkOption {
      type = lib.types.str;
      default = "loki.${homelab.baseDomain}";
      description = "URL for accessing Loki API";
    };

    retentionPeriod = lib.mkOption {
      type = lib.types.str;
      default = "30d";
      description = "How long to keep logs (e.g., 7d, 30d, 90d, 365d)";
    };
  };

  config = lib.mkIf cfg.enable {
    services.loki = {
      enable = true;
      configuration = {
        auth_enabled = false;

        common = {
          path_prefix = "/var/lib/loki";
          storage = {
            filesystem = {
              chunks_directory = "/var/lib/loki/chunks";
              rules_directory = "/var/lib/loki/rules";
            };
          };
          replication_factor = 1;
          ring = {
            instance_addr = "127.0.0.1";
            kvstore.store = "inmemory";
          };
        };

        schema_config = {
          configs = [
            {
              from = "2024-01-01";
              store = "tsdb";
              object_store = "filesystem";
              schema = "v13";
              index = {
                prefix = "index_";
                period = "24h";
              };
            }
          ];
        };

        limits_config = {
          retention_period = cfg.retentionPeriod;
          reject_old_samples = true;
          reject_old_samples_max_age = "168h";
        };

        compactor = {
          working_directory = "/var/lib/loki/compactor";
          compaction_interval = "10m";
          retention_enabled = true;
          retention_delete_delay = "2h";
          retention_delete_worker_count = 150;
          delete_request_store = "filesystem";
        };

        analytics.reporting_enabled = false;
      };
    };

    # Caddy reverse proxy configuration
    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:3100
      '';
    };
  };
}
