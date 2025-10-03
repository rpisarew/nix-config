{ ... }:
{
  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
      daemon.settings = {
        bip = "169.254.0.1/16";
      };
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };
}
