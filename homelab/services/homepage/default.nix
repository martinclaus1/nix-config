{
  config,
  lib,
  inputs,
  ...
}:
let
  service = "homepage-dashboard";
  cfg = config.homelab.services.homepage;
  homelab = config.homelab;
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
  };
  config = lib.mkIf cfg.enable {
    services.${service} = {
      enable = true;
      environmentFile = builtins.toFile "homepage.env" "HOMEPAGE_ALLOWED_HOSTS=${homelab.baseDomain}";
      settings = {
        title = "Granita Homelab";
        target = "_self";
        hideVersion = true;
        headerStyle = "boxed";
        color = "slate";
        theme = "dark";
        background = {
          opacity = 0.5;
          brightness = 0.5;
        };
      };
      customCSS = ''
        @import url('/fonts/CutiveMono-Regular.ttf');

        #information-widgets {
          background-image: linear-gradient(90deg, #d7c1ed, #96cdfb, #b5e8e0, #f28fad);
        }

        #widgets-wrap {
          justify-content: center !important;
        }

        #information-widgets-right {
          display: none;
        }

        .information-widget-greeting span {
          font-family: "Cutive Mono", monospace;
          font-weight: 400;
          font-style: normal;
          color: #11171d !important;
        }
      '';
      widgets = [
        {
          greeting = {
            textSize = "4xl";
            text = "Granita Homelab";
          };
        }
        {
          logo = {
            icon = "${homelab.assetsUrl}/icons/granita.png";
          };
        }
      ];
      services = [
        {
          "Misc" = [
            {
              "Home Assistant" = {
                href = "https://ha.martinclaus.dev";
                icon = "home-assistant.svg";
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
