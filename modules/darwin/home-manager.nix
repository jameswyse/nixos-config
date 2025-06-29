{ config, pkgs, nixpkgs, lib, home-manager, nix-vscode-extensions, ... }:

let
  user = "james";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
  programs = { } // import ../shared/home-manager.nix {
    inherit config pkgs nixpkgs lib; vscode-extensions = nix-vscode-extensions.extensions.aarch64-darwin;
  };
in
{
  imports = [
    ./dock
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.fish;
  };

  homebrew = {
    enable = true;
    taps = [ ];
    brews = [ ];
    casks = pkgs.callPackage ./casks.nix { };

    # These app IDs are from using the mas CLI app
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      # "harvest" = 506189836;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    backupFileExtension = "backup";
    users.${user} = { pkgs, config, lib, ... }: {
      home = {
        enableNixpkgsReleaseCheck = true;
        packages = pkgs.callPackage ./packages.nix { };
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];

        sessionVariables = {
          EDITOR = "nano";
          VISUAL = "code";
          SHELL = "fish";
        };

        stateVersion = "21.05";
      };

      programs = programs;

      # 
      # Removes the symlink for VSCode's settings.json
      # Re-creates VSCodes settings.json as a real file, populated with userSettings from the config.
      # This way it's mutable. I know, not ideal.. but vscode is really annoying when it can't write its own settings.
      # 
      home.activation.boforeCheckLinkTargets = {
        after = [ ];
        before = [ "checkLinkTargets" ];
        data = ''
          userDir=/Users/${user}/Library/Application\ Support/Code/User
          rm -rf "$userDir/settings.json"
        '';
      };
      # home.activation.afterWriteBoundary = {
      #   after = [ "writeBoundary" ];
      #   before = [ ];
      #   data = ''
      #     userDir=/Users/${user}/Library/Application\ Support/Code/User
      #     rm -rf "$userDir/settings.json"
      #     sudo cat ${(pkgs.formats.json {}).generate "vscode-settings" programs.vscode.profiles.default.userSettings} > "$userDir/settings.json"
      #   '';
      # };
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      entries = [
        { path = "/System/Applications/Messages.app/"; }
        { path = "/Applications/Airmail.app/"; }
        { path = "/Applications/Morgen.app/"; }
        { path = "/Applications/Slack.app/"; }
        { path = "/Applications/Google Chrome.app/"; }
        { path = "${pkgs.code-cursor}/Applications/Cursor.app/"; }
        { path = "${pkgs.ghostty}/Applications/Ghostty.app/"; }
        { path = "/Applications/GitHub Desktop.app/"; }
        { path = "/Applications/Postman.app/"; }
        { path = "/Applications/Music.app/"; }
        { path = "/Applications/Notes.app/"; }
        { path = "/Applications/Notion.app/"; }
        { path = "/Applications/Zoom.us.app/"; }
        { path = "/Applications/System Settings.app/"; }
        { path = "/Applications/OrcaSlicer.app/"; }
        # {
        #   path = "${config.users.users.${user}.home}/Downloads";
        #   section = "others";
        #   options = "--sort name --view grid --display stack";
        # }
      ];
    };
  };
}
