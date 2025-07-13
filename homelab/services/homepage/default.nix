{ config, lib, ... }:
let
  service = "homepage-dashboard";
  cfg = config.homelab.services.homepage;
in {
  options.homelab.services.homepage = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
    misc = lib.mkOption {
      default = [ ];
      type = lib.types.listOf (lib.types.attrsOf (lib.types.submodule {
        options = {
          description = lib.mkOption { type = lib.types.str; };
          href = lib.mkOption { type = lib.types.str; };
          siteMonitor = lib.mkOption { type = lib.types.str; };
          icon = lib.mkOption { type = lib.types.str; };
        };
      }));
    };
  };
  config = lib.mkIf cfg.enable { services.${service} = { enable = true; }; };

}
