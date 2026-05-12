{ config, lib, inputs, ... }: 
let
  utils = inputs.nixCats.utils;
in 
{
  imports = [
    inputs.nixCats.homeModule
  ];

  config = {
    nixCats = {
      enable = true;

      addOverlays = /* (import ./overlays inputs) ++ */ [
        (utils.standardPluginOverlay inputs)
      ];

      packageNames = [ "nvim-nixCats" ];

      luaPath = ../../config/nvim;

      categoryDefinitions.replace = ({ pkgs, settings, categories, extra, name, mkPlugin, ... }@packageDef: {
        lspsAndRuntimeDeps = {
          general = with pkgs; [
          ];
          lua = with pkgs; [
          ];
          nix = with pkgs; [
          ];
          go = with pkgs; [
          ];
        };

        startupPlugins = {
        };

        optionalPlugins = {
        };

        sharedLibraries = {
        };

        environmentVariables = {
        };

        python3.libraries = {
        };

        extraWrapperArgs = {
        };
      });

      packageDefinitions.replace = {
        nvim-nixCats = {pkgs, name, ... }: {
          settings = {
            suffix-path = true;
            suffix-LD = true;
            wrapRc = true;
            aliases = [ "nvim" "vi" "vim" ];
            hosts.python3.enable = true;
            hosts.node.enable = true;
          };
          categories = {
          };
          extra = {
          };
        };
      };
    };
  };
}
