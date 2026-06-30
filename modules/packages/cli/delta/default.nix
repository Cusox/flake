{
  flake.modules.packages = {
    homeManager.delta = {
      programs.delta = {
        enable = true;
        options = {
          features = "nordic";
          hyperlinks = true;
          side-by-side = true;
          navigate = true;
          true-color = "always";
        };
        enableGitIntegration = true;
        enableJujutsuIntegration = true;
      };

      home.file.".config/delta/themes/nordic.gitconfig".source = ./themes/nordic.gitconfig;
    };
  };
}
