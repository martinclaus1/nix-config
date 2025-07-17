{ lib, config, ... }:
let
  cfg = config.homelab;
in
{

  options.homelab = {
    enable = lib.mkEnableOption "Homelab configuration";

    timeZone = lib.mkOption {
      default = "Europe/Berlin";
      type = lib.types.str;
      description = ''
        Time zone to be used for the homelab services
      '';
    };

    baseDomain = lib.mkOption {
      default = "";
      type = lib.types.str;
      description = ''
        Base domain name to be used to access the homelab services via Caddy reverse proxy
      '';
    };

    dnsCredentialsFile = lib.mkOption {
      type = lib.types.path;
    };

    assetsUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://assets.${cfg.baseDomain}";
    };
  };

  imports = [ ./services ];

  config = lib.mkIf cfg.enable { };
}
