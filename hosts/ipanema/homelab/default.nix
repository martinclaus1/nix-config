{
  config,
  lib,
  interface,
  ...
}:
{

  homelab = {
    enable = true;
    dnsCredentialsFile = config.age.secrets.dnsApiCredentials.path;
    baseDomain = "${config.networking.hostName}.martinclaus.dev";
    machineName = config.networking.hostName;
    services = {
      defaultInterface = interface;
      enable = true;
      serveAssets = true;
      adguardhome = {
        enable = true;
        dnsBindHost = "10.55.66.22";
        hashedPassword = config.age.secrets.adguardHomePassword.path;
      };
      adguardhome-sync = {
        enable = true;
        environmentFile = config.age.secrets.adguardHomeSyncEnvironment.path;
      };
      homepage = {
        enable = true;
        customCSS = ''
          @import url('${config.homelab.assetsUrl}/fonts/CutiveMono-Regular.ttf');

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
            logo = {
              icon = "${config.homelab.assetsUrl}/icons/granita.png";
            };
          }
          {
            greeting = {
              text_size = "4xl";
              text = "${lib.toUpper (builtins.substring 0 1 config.networking.hostName)}${
                builtins.substring 1 (-1) config.networking.hostName
              } Homelab";
            };
          }
        ];
      };
      calibre-web = {
        enable = true;
        libraryDir = "/home/share/books";
      };
      tandoor = {
        enable = true;
        secretKeyFile = config.age.secrets.tandoorSecretKey.path;
      };
    };
  };
}
