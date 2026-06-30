{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.services.dockerComposeApps;
in
{
  options.services.dockerComposeApps = mkOption {
    description = "Manage Docker Compose applications natively via Systemd";
    type = types.attrsOf (
      types.submodule (
        { name, ... }:
        {
          options = {
            enable = mkEnableOption "Enable Docker Compose app ${name}";

            composeFile = mkOption {
              type = types.path;
              description = "Path to the main docker-compose.yml file.";
            };

            overrideFile = mkOption {
              type = types.nullOr types.path;
              default = null;
              description = "Optional path to a docker-compose.override.yml file.";
            };

            sopsSecretName = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "The name of the SOPS secret containing the .env variables.";
            };
          };
        }
      )
    );
    default = { };
  };

  config = mkIf (cfg != { }) {
    systemd.services = mkMerge (
      mapAttrsToList (
        name: app:
        mkIf app.enable {
          "docker-compose-${name}" = {
            description = "Docker Compose Service: ${name}";
            wantedBy = [ "multi-user.target" ];
            after = [
              "docker.service"
              "docker.socket"
            ]
            ++ (optional (app.sopsSecretName != null) "sops-nix.service");
            requires = [ "docker.service" ];

            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };

            script =
              let
                baseArg = "-f ${app.composeFile}";
                overrideArg = if app.overrideFile != null then "-f ${app.overrideFile}" else "";
                envArg =
                  if app.sopsSecretName != null then
                    "--env-file ${config.sops.secrets.${app.sopsSecretName}.path}"
                  else
                    "";
              in
              ''
                ${pkgs.docker}/bin/docker compose ${baseArg} ${overrideArg} ${envArg} up -d --remove-orphans
              '';

            preStop =
              let
                baseArg = "-f ${app.composeFile}";
                overrideArg = if app.overrideFile != null then "-f ${app.overrideFile}" else "";
                envArg =
                  if app.sopsSecretName != null then
                    "--env-file ${config.sops.secrets.${app.sopsSecretName}.path}"
                  else
                    "";
              in
              ''
                ${pkgs.docker}/bin/docker compose ${baseArg} ${overrideArg} ${envArg} down
              '';
          };
        }
      ) cfg
    );
  };
}
