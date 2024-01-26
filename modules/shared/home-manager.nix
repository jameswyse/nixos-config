{ config, pkgs, vscode-extensions, lib, ... }:

let
  name = "James Wyse";
  user = "james";
  email = "james@jameswyse.net";
in
{
  # 
  # Git
  # 
  git = {
    enable = true;
    ignores = [ "*.swp" ];
    userName = name;
    userEmail = email;
    lfs = {
      enable = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      core = {
        editor = "nano";
        autocrlf = "input";
      };
      commit.gpgsign = false;
      pull.rebase = true;
      rebase.autoStash = true;
    };
  };

  # 
  # Fish Shell
  # 
  fish = {
    enable = true;
    shellInit = ''
      fzf_configure_bindings --directory=\cf
      fzf_configure_bindings --git_log=\cg
      fzf_configure_bindings --git_status=\cs
      fzf_configure_bindings --history=\cr
      fzf_configure_bindings --variables=\cv
      fzf_configure_bindings --processes=\cp
    '';
    interactiveShellInit = lib.mkMerge [
      ''
        set fish_greeting
        fish_add_path /nix/var/nix/profiles/default/bin 
        fish_add_path /run/current-system/sw/bin
        fish_add_path /run/wrappers/bin
        fish_add_path /usr/bin/env

        alias ls="eza --icons=auto"
        alias ns="c nixos-config; and nix run .#build-switch"
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        ''
          fish_add_path /home/${user}/.apps 
          fish_add_path /home/${user}/.nix-profile/bin
          fish_add_path /home/${user}/.local/share/bin/
        '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
          fish_add_path /Users/${user}/.nix-profile/bin 
          fish_add_path /opt/homebrew/bin
          fish_add_path /opt/homebrew/sbin
          fish_add_path /Applications/Postgres.app/Contents/Versions/16/bin
        '')
    ];
    plugins = [
      {
        name = "fzf.fish";
        src = pkgs.fishPlugins.fzf-fish.src;
      }
      {
        name = "jameswyse";
        src = pkgs.fetchFromGitHub {
          owner = "jameswyse";
          repo = "fish-plugins";
          rev = "e6b27f6a3fdd92386ccb8deede7dc35b9a8bc648";
          sha256 = "sha256-8H8WuTDCyKVZs3p4x3jCmkBjvjcW1vCoGXnvyzIhR28=";
        };
      }
    ];

    shellAbbrs = {
      l = "ls -a";
      ll = "ls -al";
    };
  };

  # 
  # Starship Prompt
  # 
  starship = {
    enable = true;
    enableFishIntegration = true;
    settings = pkgs.lib.importTOML ../../config/starship.toml;
  };

  # 
  # fzf - fuzzy finder
  # 
  fzf.enable = true;

  # 
  # tealdeer - tldr command
  # 
  tealdeer = {
    enable = true;
    settings = { auto_update = true; };
  };

  # 
  # Zoxide - z command to quickly jump to directories
  # 
  zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  # 
  # SSH
  # 
  ssh = {
    enable = true;
    extraConfig = lib.mkMerge [
      ''
        Host github.com
          Hostname github.com
          IdentitiesOnly yes
      ''
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        ''
          IdentityFile /home/${user}/.ssh/id_ed25519
        '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
          IdentityFile /Users/${user}/.ssh/id_ed25519
        '')
    ];
  };

  # 
  # Kitty terminal
  # 
  kitty = {
    enable = true;
    shellIntegration.enableFishIntegration = true;
    settings = {
      background_opacity = "0.9";
      font_size = "10.0";
      font_family = "FiraCode Nerd Font";
      bold_font = "auto";
      italic_font = "auto";
      bold_italic_font = "auto";
      enable_audio_bell = false;
      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      tab_bar_edge = "top";
      tab_bar_margin_height = "0.0 0.0";
      scrollback_lines = -1;
      allow_remote_control = "yes";
      shell_integration = "enabled";
      macos_option_as_alt = "yes";
      enabled_layouts = "fat:bias=50;full_size=1;mirrored=false";
    };
    theme = "Dracula";
  };

  # 
  # VSCode editor
  # 
  vscode = {
    enable = true;
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
    mutableExtensionsDir = false;

    extensions = with vscode-extensions.vscode-marketplace; [
      jnoortheen.nix-ide
      catppuccin.catppuccin-vsc
      catppuccin.catppuccin-vsc-icons
      roman.ayu-next
      adpyke.vscode-sql-formatter
      dbaeumer.vscode-eslint
      dotenv.dotenv-vscode
      dsznajder.es7-react-js-snippets
      eamodio.gitlens
      ecmel.vscode-html-css
      esbenp.prettier-vscode
      mgmcdermott.vscode-language-babel
      mquandalle.graphql
      ms-azuretools.vscode-docker
      ms-python.isort
      ms-python.python
      ms-python.vscode-pylance
      rvest.vs-code-prettier-eslint
      tamasfe.even-better-toml
      gulajavaministudio.mayukaithemevsc
    ];

    userSettings = {
      "workbench.iconTheme" = "catppuccin-macchiato";
      "workbench.colorTheme" = "Mayukai Semantic Mirage";

      "editor.fontFamily" = "'Fira Code', 'Droid Sans Mono', 'monospace', monospace";
      "extensions.autoCheckUpdates" = false;
      "update.mode" = "none";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.formatterPath" = "nixpkgs-fmt";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = { "command" = [ "nixpkgs-fmt" ]; };
        };
      };
      "files.associations" = {
        ".env*" = "dotenv";
      };

      "git.enableCommitSigning" = false;
      "editor.formatOnPaste" = true;
      "editor.formatOnSave" = true;
      "[javascript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
      "[typescriptreact]" = {
        "editor.defaultFormatter" = "vscode.typescript-language-features";
      };
      "editor.tokenColorCustomizations" = {
        "textMateRules" = [
          {
            "scope" = "keyword.other.dotenv";
            "settings" = {
              "foreground" = "#FF000000";
            };
          }
        ];
      };
    };
  };
}
