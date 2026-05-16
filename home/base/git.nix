{
  programs.git = {
    enable = true;
    signing = {
      key = null;
      format = null;
      signByDefault = null;
      signer = null;
    };
    settings = import ../../config/git/settings.nix;
  };

  programs.git-credential-oauth = {
    enable = true;
    extraFlags = [ "-device" ];
  };
}
