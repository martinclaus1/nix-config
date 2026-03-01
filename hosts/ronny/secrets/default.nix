{ inputs, ... }: {
  age.secrets = {
    forgejoAdminCredentials.file = "${inputs.secrets}/forgejoAdminCredentials.age";
    forgejoUserCredentials.file = "${inputs.secrets}/forgejoUserCredentials.age";
  };
}
