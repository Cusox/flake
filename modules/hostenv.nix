let
  hostConfigPath = builtins.getEnv "HOST_CONFIG";
in
{
  checkHostConfigPath =
    if hostConfigPath == "" then
      throw "HOST_CONFIG is empty. Use scripts/decrypted-vps.sh ."
    else
      hostConfigPath;
}
