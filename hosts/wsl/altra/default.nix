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

  wsl.enable = true;
  wsl.defaultUser = user.username;

  networking.hostName = hostName;

  environment = {
    pathsToLink = [ "/share/zsh" ];

    systemPackages = with pkgs; [
      git
      curl
      wget
    ];
  };

  programs.zsh.enable = true;

  users.users = {
    ${user.username} = {
      linger = true;
      shell = pkgs.zsh;
    };
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "25.11";
}
