{ flake, inputs, perSystem, pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    # bring in the nixos-vscode-server module
    inputs.vscode-server.nixosModules.default
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;  # keep only N generations on the ESP

  networking.hostName = "matrix";
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];

  time.timeZone = "Europe/Berlin";

  # Kernel & hardware defaults
  system.stateVersion = "24.11"; # set to your installed release

  # Packages available system-wide (keep this small; prefer Home Manager for apps)
  environment.systemPackages = with perSystem.nixpkgs; [
    bashInteractive
    coreutils
    gnugrep
    gnutar
    gzip
    unzip
    curl
    which

    atuin
    btop
    bat
    ripgrep
    zoxide
    git
    neovim
    wget
    starship
    wezterm
    # spotify
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Enable the VS Code server helper
  services.vscode-server.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT = "de_DE.UTF-8";
    LC_MONETARY = "de_DE.UTF-8";
    LC_NAME = "de_DE.UTF-8";
    LC_NUMERIC = "de_DE.UTF-8";
    LC_PAPER = "de_DE.UTF-8";
    LC_TELEPHONE = "de_DE.UTF-8";
    LC_TIME = "de_DE.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the Cinnamon Desktop Environment.
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.desktopManager.cinnamon.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # OpenSSH (server)
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    # secure defaults
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      KbdInteractiveAuthentication = false;
      X11Forwarding = false;
    };
  };

  # Optional: firewall (22 open)
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  users.users = {
    # Admin
    lowm4n = {
      isNormalUser = true;
      description = "LowM4N Admin";
      extraGroups = ["wheel" "networkmanager"];
      # shell = pkgs.fish;
      shell = pkgs.bashInteractive;
      hashedPassword = "$y$j9T$zKVMZna.IIvgengXVjppm.$ZnAjitNKQssZQzuyKX413Jct2bVpRuqeHZBUAmgYy31"; # or set to "!" to lock password
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC7PcPvy917XSLd/qqWUT4nHT9ML6tn/zVfbMTcAbQ9ztKGRYDLoHnKIBpIGnOJxeBQ7tHtp3r5oG3h0vatJM0+E8psJElw1Bx8iTjMD3m6bZ/l9lJmJ5tAEv8C+9n0nJ9NuzgSSbmscxutxxU8p0DpmsnIUMaByTL/1f3bB/tddOO0KFiWPKLx8bIhB0SDL6iix7dXPbvthijYj8sXkSUyNfE7jfwFHZJQz1DUg/qc9ggrrkWpvwKDPuF4kCTO2punp7VpxYAvlgYpVjK2H5qUw0dYslSoCFB3CFfd+uKFaVEgTwH36yBLspgafMQ7Df3ujBAqB/nhvRsnJ44KXZn+k9MVEcDjmjOUDTmZ1rmjWXSOrIVO+QukpCSCji9azXOBJzHe4KWziJ1dYprEYzpbVRCk67VFCZ2Y0ybmbeHzStJOGTPRXZCMzM97FwxmResEOH8Lmww3UQis7Vb0VUvVyW6RxoXb1Sbgj3C0N7HO3LwxTuga1jOZgshJ+s8ZR3JBwtrJjWHxFHClJEAUgdSHkClQ+sbL2Ii9df4e43S30dCEGVpw5HY3TYvvo7UYOEdUoYvlc9CYE+d5s+ka5bFA/Frc0YPlPojwy5CttnWKN1JM3HACx471vKufsNMTQHlspDAFtrl6rHUX6F4vMvPyC34kgR2xG4chuSzybmJcsQ== lowm4n@JARVIS.local"
      ];
    };
  };
}
