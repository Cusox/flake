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
      };
    };
  };
}
