{ pkgs, ... }:
{
  # Home Manager basics
  home.stateVersion = "24.11"; # match your HM release

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
    style.name = "kvantum";
  };

  # Shell / prompt
  programs.fish.enable = true;
  programs.bash = {
    enable = true;
    # Runs for interactive bash
    initExtra = ''
      if [[ $- == *i* ]] && [[ -z "$FISH_VERSION" ]]; then
        exec ${pkgs.fish}/bin/fish -l
      fi
    '';
  };
  programs.starship.enable = true;

  # Useful CLI apps (user-scoped)
  home.packages = with pkgs; [ ripgrep fd bat ];

  # Git defaults
  programs.git = {
    enable = true;
    userName = "Foo Bar";
    userEmail = "foo@bar.com";
  };

  # SSH client config (optional tweaks)
  programs.ssh = {
    enable = true;
    matchBlocks."*".extraOptions = {
      ServerAliveInterval = "30";
      ServerAliveCountMax = "3";
    };
  };
}
