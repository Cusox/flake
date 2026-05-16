{ pkgs, inputs, ... }:
let
  llm-agents = inputs.llm-agents;
in
{
  home.packages = [
    llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi
  ];
}
