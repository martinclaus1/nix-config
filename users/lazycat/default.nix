{ pkgs, ... }:
let
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzXbYP1RH7+Lqlx65uzIyLe7XtoIlfqE+C9rvP0tqNt"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICX6mqgg8gx2PIODrvKl5sOR+EW4mDM5w3zREn1vDYUW"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELaMlG7yEFF+959jfYlGQd2K2mpxVLX6sWHj/ITWOB+"
  ];

in
{
  nix.settings.trusted-users = [ "lazycat" ];

  boot.initrd.network.ssh.authorizedKeys = sshKeys;

  security.sudo.wheelNeedsPassword = false;
  users.users = {
    lazycat = {
      shell = pkgs.zsh;
      uid = 1000;
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      group = "lazycat";
      openssh.authorizedKeys.keys = sshKeys;
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
