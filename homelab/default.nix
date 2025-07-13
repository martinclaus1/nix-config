{ lib, config, ... }:
let cfg = config.homelab;
in {

  options.homelab = {
    enable = lib.mkEnableOption "Homelab configuration";
    timeZone = lib.mkOption {
      default = "Europe/Berlin";
      type = lib.types.str;
      description = ''
        Time zone to be used for the homelab services
      '';
    };
  };

  imports = [ ./services ];

  config = lib.mkIf cfg.enable { };
}
