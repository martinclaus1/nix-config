{ config, lib, ... }:
let
  cfg = config.homelab.services.adguardhome-sync;
  homelab = config.homelab;
in
{
  options.homelab.services.adguardhome-sync = {
    enable = lib.mkEnableOption { description = "Enable AdGuard Home"; };
    environmentFile = lib.mkOption {
      type = lib.types.path;
      default = "";
      description = "The path to the environment file containing the AdGuard Home Sync configuration";
    };
  };
  config = lib.mkIf cfg.enable {
    virtualisation = {
      podman.enable = true;
      oci-containers.containers.adguardhome-sync = {
        image = "ghcr.io/bakito/adguardhome-sync";
        autoStart = true;
        cmd = [ "run" ];
        environmentFiles = [ cfg.environmentFile ];
        environment = {
          TZ = homelab.timeZone;
        };
        extraOptions = [
          "--add-host=host.docker.internal:host-gateway"
        ];
      };
    };
  };
}
