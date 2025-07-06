{ config, lib, pkgs, ... }:

{
  options = {
    sshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzXbYP1RH7+Lqlx65uzIyLe7XtoIlfqE+C9rvP0tqNt"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICX6mqgg8gx2PIODrvKl5sOR+EW4mDM5w3zREn1vDYUW"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELaMlG7yEFF+959jfYlGQd2K2mpxVLX6sWHj/ITWOB+"
      ];
      description = "SSH keys for the system";
    };
  };

  config = {
    # Define common packages as a system-wide variable
    environment.systemPackages = with pkgs; [
      htop
      tmux
      git
      curl
      wget
      rsync
      neovim
    ];
  };
}
