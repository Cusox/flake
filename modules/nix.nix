{
  flake.modules.nixos.nix = {
    nix = {
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };

      optimise.automatic = true;

      settings = {
        experimental-features = [
          "nix-command"
          "flakes"
        ];

        auto-optimise-store = true;

        substituters = [
          "https://mirrors.ustc.edu.cn/nix-channels/store/"
          "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store/"
          "https://mirror.sjtu.edu.cn/nix-channels/store"
          "https://nix-community.cachix.org/"
        ];
        trusted-public-keys = [
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        ];
      };
    };
  };
}
