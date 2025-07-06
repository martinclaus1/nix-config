{
  sshKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICzXbYP1RH7+Lqlx65uzIyLe7XtoIlfqE+C9rvP0tqNt"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICX6mqgg8gx2PIODrvKl5sOR+EW4mDM5w3zREn1vDYUW"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIELaMlG7yEFF+959jfYlGQd2K2mpxVLX6sWHj/ITWOB+"
  ];
  
  commonPackages = pkgs: with pkgs; [
    htop
    tmux
    git
    curl
    wget
    rsync
    neovim
  ];
}
