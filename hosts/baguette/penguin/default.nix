{
  pkgs,
  hostName,
  user,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  hardware.graphics.enable = true;

  environment = {
    pathToLink = [ "/share/zsh" ];

    systemPackages = with pkgs; [
      git
      curl
      wget
      neovim
    ];
  };

  networking.hostName = hostName;

  users.users = {
    ${user.username} = {
      isNormalUser = true;
      uid = 1000;
      linger = true;
      extraGroups = [ "wheel" ];
    };
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
