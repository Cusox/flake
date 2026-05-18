{ pkgs, inputs, ... }:
let
  llm-agents = inputs.llm-agents;
in
{
  home.packages = [
    llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
  ];

  home.file = {
    ".pi/agent/extensions" = {
      source = ../config/pi/extensions;
      recursive = true;
    };

    ".pi/agent/permission.settings.json".source = ../config/pi/permission.settings.json;
  };
}
