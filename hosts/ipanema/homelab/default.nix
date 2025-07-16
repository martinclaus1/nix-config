{ config, ... }:
{

  homelab = {
    enable = true;
    dnsCredentialsFile = config.age.secrets.dnsApiCredentials.path;
    baseDomain = "aperol.martinclaus.dev";
    services = {
      enable = true;
      homepage = {
        enable = true;
      };
    };
  };
}
