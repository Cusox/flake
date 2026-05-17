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

  wsl = {
    enable = true;
    defaultUser = user.username;

    wslConf = {
      network = {
        generateResolvConf = false;
      };
    };
  };

  networking.hostName = hostName;

  environment = {
    pathsToLink = [ "/share/zsh" ];

    systemPackages = with pkgs; [
      git
      curl
      wget
    ];

    etc."resolv.conf".txt = ''
      nameserver 192.168.31.3
    '';
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
