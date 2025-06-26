{ agenix, config, nix-vscode-extensions, pkgs, ... }:

let user = "james"; in

{

  imports = [
    ../../modules/darwin/secrets.nix
    ../../modules/darwin/home-manager.nix
    ../../modules/shared
    ../../modules/shared/cachix
    agenix.darwinModules.default
  ];

  # Setup user, packages, programs
  nix = {
    enable = true;
    package = pkgs.nixVersions.latest;
    settings.trusted-users = [ "@admin" "${user}" ];

    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };
      options = "--delete-older-than 30d";
    };

    # Turn this on to make command line easier
    extraOptions = ''
      experimental-features = nix-command flakes auto-allocate-uids
    '';
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    allowInsecure = false;
    allowUnsupportedSystem = true;
  }; 

  programs = {
    fish.enable = true;
  };

  services.redis.enable = true;
  services.redis.dataDir = "/var/lib/redis";

  # users.users = {
  #   ${user} = {
  #     shell = pkgs.fish;
  #     # openssh.authorizedKeys.keys = keys;
  #   };
  # };

  environment.shells = with pkgs; [ fish ];

  # Turn off NIX_PATH warnings now that we're using flakes
  system.checks.verifyNixPath = false;

  # Load configuration that is shared across systems
  environment.systemPackages = with pkgs; [
    agenix.packages."${pkgs.system}".default
  ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });

  system = {
    stateVersion = 4;
    primaryUser = user;

    defaults = {
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        ApplePressAndHoldEnabled = false;
        AppleInterfaceStyle = "Dark";

        # 120, 90, 60, 30, 12, 6, 2
        KeyRepeat = 2;

        # 120, 94, 68, 35, 25, 15
        InitialKeyRepeat = 15;

        "com.apple.mouse.tapBehavior" = 1;
        "com.apple.sound.beep.volume" = 0.0;
        "com.apple.sound.beep.feedback" = 0;
      };

      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      dock = {
        autohide = false;
        show-recents = false;
        launchanim = true;
        orientation = "bottom";
        tilesize = 64;
        appswitcher-all-displays = true;
        wvous-tr-corner = 10;
        wvous-bl-corner = 4;
      };

      finder = {
        ShowStatusBar = true;
        FXPreferredViewStyle = "Nlsv";
        AppleShowAllExtensions = true;
        QuitMenuItem = true;
        FXEnableExtensionChangeWarning = false;
        _FXShowPosixPathInTitle = false;
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
    };

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
}
