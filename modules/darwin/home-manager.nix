{ config, pkgs, lib, home-manager, nix-vscode-extensions, ... }:

let
  user = "james";
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
in
{
  imports = [
   ./dock
  ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.nushell;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};

    # These app IDs are from using the mas CLI app
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "harvest" = 506189836;
    };
  };

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }:{
      home = {
        enableNixpkgsReleaseCheck = false;
        packages = pkgs.callPackage ./packages.nix {};
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
        ];

        sessionVariables = {
          EDITOR = "nano";
          VISUAL = "code";
          SHELL = "nu";
        };

        stateVersion = "21.05";
      };
      programs = {} // import ../shared/home-manager.nix { inherit config pkgs lib; vscode-extensions = nix-vscode-extensions.extensions.aarch64-darwin; };

      # Marked broken Oct 20, 2022 check later to remove this
      # https://github.com/nix-community/home-manager/issues/3344
      manual.manpages.enable = false;
    };
  };

  # Fully declarative dock using the latest from Nix Store
  local = { 
    dock = {
      enable = true;
      entries = [
        { path = "/System/Applications/Messages.app/"; }
        { path = "/Applications/Spark Desktop.app/"; }
        { path = "/Applications/Slack.app/"; }
        { path = "/Applications/Google Chrome.app/"; }
        { path = "/Applications/Visual Studio Code.app/"; }
        { path = "${pkgs.kitty}/Applications/Kitty.app/"; }
        { path = "/Applications/GitHub Desktop.app/"; }
        { path = "/Applications/Postman.app/"; }
        { path = "/Applications/Amie.app/"; }
        { path = "/Applications/Music.app/"; }
        { path = "/Applications/Notes.app/"; }
        { path = "/Applications/Notion.app/"; }
        { path = "/Applications/Zoom.us.app/"; }
        { path = "/Applications/System Settings.app/"; }
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
