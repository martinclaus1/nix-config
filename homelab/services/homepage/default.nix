{
  config,
  lib,
  ...
}:
let
  service = "homepage-dashboard";
  cfg = config.homelab.services.homepage;
  homelab = config.homelab;
  capitalizeFirst =
    str: if str == "" then "" else (lib.toUpper (lib.substring 0 1 str)) + (lib.substring 1 (-1) str);

  machineName = capitalizeFirst homelab.machineName;
in
{
  options.homelab.services.homepage = {
    enable = lib.mkEnableOption { description = "Enable ${service}"; };
    misc = lib.mkOption {
      default = [ ];
      type = lib.types.listOf (
        lib.types.attrsOf (
          lib.types.submodule {
            options = {
              description = lib.mkOption { type = lib.types.str; };
              href = lib.mkOption { type = lib.types.str; };
              siteMonitor = lib.mkOption { type = lib.types.str; };
              icon = lib.mkOption { type = lib.types.str; };
            };
          }
        )
      );
    };
    customCSS = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Custom CSS to be applied to the homepage dashboard";
    };
    widgets = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "Widgets to be displayed on the homepage dashboard";
    };
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      environmentFile = builtins.toFile "homepage.env" "HOMEPAGE_ALLOWED_HOSTS=${homelab.baseDomain}";
      settings = {
        title = "${machineName} Homelab";
        target = "_self";
        hideVersion = true;
        headerStyle = "boxed";
        color = "slate";
        theme = "dark";
        background = {
          opacity = 50;
          brightness = 50;
          image = "${homelab.assetsUrl}/images/lake_como.webp";
        };
        favicon = "${homelab.assetsUrl}/icons/granita.png";
      };
      customCSS = if cfg.customCSS != null then cfg.customCSS else null;
      widgets = cfg.widgets;
      services =
        let
          homepageCategories = [
            "Services"
            "Content"
          ];
          hl = config.homelab.services;
          homepageServices =
            x:
            (lib.attrsets.filterAttrs (
              name: value: value ? homepage && value.homepage.category == x
            ) homelab.services);
        in
        lib.lists.forEach homepageCategories (cat: {
          "${cat}" =
            lib.lists.forEach (lib.attrsets.mapAttrsToList (name: value: name) (homepageServices "${cat}"))
              (x: {
                "${hl.${x}.homepage.name}" = {
                  icon = hl.${x}.homepage.icon;
                  description = hl.${x}.homepage.description;
                  href = "https://${hl.${x}.url}";
                  siteMonitor = "https://${hl.${x}.url}";
                };
              });
        })
        ++ [
          {
            "Misc" = [
              {
                "Home Assistant" = {
                  href = "https://ha.martinclaus.dev";
                  icon = "home-assistant.svg";
                  description = "Home Assistant is an open-source home automation platform that focuses on privacy and local control.";
                  siteMonitor = "https://ha.martinclaus.dev";
                };
              }
            ];
          }
        ];
    };
    services.caddy.virtualHosts."${homelab.baseDomain}" = {
      useACMEHost = homelab.baseDomain;
      extraConfig = ''
        reverse_proxy http://127.0.0.1:${toString config.services.${service}.listenPort}
      '';
    };
  };

}
