{
  inputs,
  lib,
  pkgs,
  ...
}:

{
  nix.settings.experimental-features = lib.mkDefault [
    "nix-command"
    "flakes"
  ];

  time.timeZone = "Europe/Berlin";

  security = {
    doas.enable = lib.mkDefault false;
    sudo = {
      enable = lib.mkDefault true;
      wheelNeedsPassword = lib.mkDefault false;
    };
  };

  # Define common packages as a system-wide variable
  environment.systemPackages = with pkgs; [
    htop
    tmux
    git
    curl
    wget
    rsync
    neovim
    vim
    just
    inputs.agenix.packages."${system}".default
  ];

  imports = [ ./secrets ];
}
