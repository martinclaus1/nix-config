{ inputs, ... }: {
  age.secrets = {
    adguardHomePassword.file = "${inputs.secrets}/adguardHomePassword.age";
  };
}
