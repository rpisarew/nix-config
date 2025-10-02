{ pkgs, ... }:
{
  # Home Manager basics
  home.stateVersion = "25.05"; # match your HM release

  # Declarative cursor config that updates GTK & X11
  home.pointerCursor = {
    name = "Bibata-Modern-Classic";  # or "Adwaita"
    package = pkgs.bibata-cursors;
    size = 24;
    gtk.enable = true;  # writes gtk settings
    x11.enable = true;  # sets X cursor symlink
  };

  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
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
  home.packages = with pkgs; [ bibata-cursors ripgrep fd bat ];

  # Git defaults
  programs.git = {
    enable = true;
    userName = "Foo Bar";
    userEmail = "foo@bar.com";
  };
}
