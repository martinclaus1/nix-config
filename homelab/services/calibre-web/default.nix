{ config, lib, ... }:
let
  cfg = config.homelab.services.calibre-web;
  homelab = config.homelab;
  service = "calibre-web";
in
{
  options.homelab.services.${service} = {
    enable = lib.mkEnableOption { description = "Enable Calibre Web"; };

    configDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/${service}";
    };

    libraryDir = lib.mkOption {
      type = lib.types.str;
      default = "/mnt/user/books";
      description = "Directory where the Calibre library is stored";
    };

    url = lib.mkOption {
      type = lib.types.str;
      default = "books.${homelab.baseDomain}";
    };

    homepage.name = lib.mkOption {
      type = lib.types.str;
      default = "Calibre Web";
    };

    homepage.description = lib.mkOption {
      type = lib.types.str;
      default = "Calibre Web is a web application for browsing, reading, and managing eBooks stored in a Calibre library.";
    };

    homepage.icon = lib.mkOption {
      type = lib.types.str;
      default = "calibre-web.svg";
    };

    homepage.category = lib.mkOption {
      type = lib.types.str;
      default = "Content";
    };
  };

  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      user = homelab.user;
      group = homelab.group;
      dataDir = cfg.configDir;
      options = {
        calibreLibrary = cfg.libraryDir;
      };
    };

    services.caddy.virtualHosts."${cfg.url}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString config.services.${service}.listen.port}
      '';
    };
  };
}
