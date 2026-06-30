{ lib, ... }:
{
  flake.modules.packages = {
    nixos.zsh = {
      programs.zsh.enable = true;

      environment.pathsToLink = [
        "/share/zsh"
      ];
    };

    homeManager.zsh =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          zsh-fzf-tab
          zsh-fast-syntax-highlighting
        ];

        programs.zsh = {
          enable = true;

          completionInit = "autoload -U compinit && compinit -i";

          autosuggestion = {
            enable = true;
          };

          sessionVariables = {
            LESSCHARSET = "utf-8";
            SHELL = "${pkgs.zsh}/bin/zsh";
            NODE_USE_ENV_PROXY = 1;
          };

          initContent = lib.mkMerge [
            (lib.mkOrder 600 ''
              source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
            '')
            (lib.mkAfter ''
              source ${pkgs.zsh-fast-syntax-highlighting}/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
            '')
          ];

          envExtra = ''
            [[ -r ~/.config/zsh/local.zshenv ]] && source ~/.config/zsh/local.zshenv
          '';

          history = {
            append = true;
            size = 50000;
            save = 50000;
            ignoreAllDups = true;
            expireDuplicatesFirst = true;
          };
        };
      };
  };
}
