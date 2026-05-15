{
  programs.jujutsu = {
    enable = true;

    settings = import ../../config/jj/settings.nix;
  };
}
