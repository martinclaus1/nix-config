{
  config,
  pkgs,
  ...
}:
{
  nix.settings.trusted-users = [ "lazycat" ];

  users.users = {
    lazycat = {
      shell = pkgs.zsh;
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      group = "lazycat";
      openssh.authorizedKeys.keys = config.sshKeys;
    };
    root = {
      openssh = {
        authorizedKeys.keys = [ ];
      };
    };
  };

  users.groups = {
    lazycat = {
      gid = 1000;
    };
  };

  programs.zsh.enable = true;
}
