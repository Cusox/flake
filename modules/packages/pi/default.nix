{ inputs, ... }:
{
  flake.modules.packages = {
    homeManager.pi =
      { pkgs, ... }:
      {
        home.packages = [
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
        ];

        home.file = {
          ".pi/agent/extensions" = {
            source = ./pi/extensions;
            recursive = true;
          };

          ".pi/agent/permission.settings.json".source = ./pi/permission.settings.json;
        };
      };
  };
}
