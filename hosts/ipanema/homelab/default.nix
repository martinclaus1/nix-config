{ config, ... }: {

  homelab = {
    enable = true;
    dnsCredentialsFile = config.age.secrets.dnsApiCredentials.path;
    baseDomain = "ipanema.martinclaus.dev";
    machineName = "ipanema";
    services = {
      enable = true;
      serveAssets = true;
      adguardhome = {
        enable = false;
        hashedPassword = config.age.secrets.adguardHomePassword.path;
      };
      adguardhome-sync = {
        enable = false;
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
            logo = { icon = "${config.homelab.assetsUrl}/icons/granita.png"; };
          }
          {
            greeting = {
              text_size = "4xl";
              text = "Ipanema Homelab";
            };
          }
        ];
      };
    };
  };
}
