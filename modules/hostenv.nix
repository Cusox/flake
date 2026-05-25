let
  hostName = builtins.getEnv "VPS_BOOTSTRAP_HOST";

  hostConfigPath = builtins.getEnv "VPS_BOOTSTRAP_CONFIG";
in
{
  checkHostName =
    if hostName == "" then
      throw "VPS_BOOTSTRAP_HOST is empty. Use scripts/build-vps-bootstrap-image.sh <host>."
    else
      hostName;

  checkHostConfigPath =
    if hostConfigPath == "" then
      throw "VPS_BOOTSTRAP_CONFIG is empty. Use scripts/build-vps-bootstrap-image.sh <host>."
    else
      hostConfigPath;
}
