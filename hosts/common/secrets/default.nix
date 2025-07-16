{
  inputs,
  ...
}:
{
  age = {
    identityPaths = [ "/home/lazycat/.ssh/id_ed25519" ];
    secrets = {
      dnsApiCredentials.file = "${inputs.secrets}/dnsApiCredentials.age";
      dnsContactEmail.file = "${inputs.secrets}/dnsContactEmail.age";
    };
  };
}
