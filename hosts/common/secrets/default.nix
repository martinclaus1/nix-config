{
  inputs,
  ...
}:
{
  age = {
    identityPaths = [ "/home/lazycat/.ssh/agenix_key" ];
    secrets = {
      dnsApiCredentials.file = "${inputs.secrets}/dnsApiCredentials.age";
    };
  };
}
