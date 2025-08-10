{ inputs, ... }: {
  age.secrets = {
    adguardHomePassword.file = "${inputs.secrets}/adguardHomePassword.age";
    adguardHomeSyncEnvironment.file =
      "${inputs.secrets}/adguardHomeSyncEnvironment.age";
    tandoorSecretKey.file = "${inputs.secrets}/tandoorSecretKey.age";
  };
}
