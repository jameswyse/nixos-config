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
      credential.helper = "manager";
      credential."https://github.com".username = "jameswyse";
      extraConfig.credential.credentialStore = "cache";
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
        fish_add_path /Users/james/.npm-packages/bin
        set -a fish_user_paths ./node_modules/.bin
        set -x TERM xterm-256color

        fnm env --use-on-cd --corepack-enabled --shell fish | source

        alias ls="eza --icons=auto"
        alias ns="c nixos/nixos-config; and nix run .#build-switch"
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
          
          if [ -f '/Users/${user}/google-cloud-sdk/path.fish.inc' ]; . '/Users/${user}/google-cloud-sdk/path.fish.inc'; end

          set -gx PNPM_HOME "/Users/${user}/Library/pnpm"
          if not string match -q -- $PNPM_HOME $PATH
            set -gx PATH "$PNPM_HOME" $PATH
          end
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
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux
        ''
          IdentityFile /home/${user}/.ssh/id_ed25519
        '')
      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin
        ''
          IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
          IdentityFile /Users/${user}/.ssh/id_ed25519
        '')
            ''
      Host github.com
        Hostname github.com
        IdentitiesOnly yes
      ''
    ];
  };

  # ghostty = {
  #   enable = true;
  #   enableZshIntegration = true;

  #   settings = {
  #     auto-update = "off";
  #     font-size = 13;
  #     font-feature = "-liga";
  #     # font-family = "FiraCode Nerd Font Mono";
  #     shell-integration-features = "sudo";
  #   };
  # };

  # vscode = {
  #   enable = true;
  #   mutableExtensionsDir = true;
  #   profiles = {
  #     default = {
  #       enableExtensionUpdateCheck = true;
  #       enableUpdateCheck = true;
  #       extensions = [
  #         vscode-extensions.vscode-marketplace.alefragnani.project-manager
  #         vscode-extensions.open-vsx.anysphere.pyright
  #         vscode-extensions.vscode-marketplace.bradlc.vscode-tailwindcss
  #         vscode-extensions.vscode-marketplace.catppuccin.catppuccin-vsc
  #         vscode-extensions.vscode-marketplace.catppuccin.catppuccin-vsc-icons
  #         vscode-extensions.vscode-marketplace.dbaeumer.vscode-eslint
  #         vscode-extensions.vscode-marketplace.dotenv.dotenv-vscode
  #         vscode-extensions.vscode-marketplace.dsznajder.es7-react-js-snippets
  #         vscode-extensions.vscode-marketplace.eamodio.gitlens
  #         vscode-extensions.vscode-marketplace.ecmel.vscode-html-css
  #         vscode-extensions.vscode-marketplace.esbenp.prettier-vscode
  #         vscode-extensions.vscode-marketplace.github.vscode-github-actions
  #         vscode-extensions.vscode-marketplace.gulajavaministudio.mayukaithemevsc
  #         vscode-extensions.vscode-marketplace.jnoortheen.nix-ide
  #         vscode-extensions.vscode-marketplace.lokalise.i18n-ally
  #         vscode-extensions.vscode-marketplace.mattpocock.ts-error-translator
  #         vscode-extensions.vscode-marketplace.mgmcdermott.vscode-language-babel
  #         vscode-extensions.vscode-marketplace.mquandalle.graphql
  #         # vscode-extensions.vscode-marketplace.ms-azuretools.vscode-docker
  #         # vscode-extensions.vscode-marketplace.ms-python.isort
  #         # vscode-extensions.vscode-marketplace.ms-python.python
  #         # vscode-extensions.vscode-marketplace.ms-python.vscode-pylance
  #         vscode-extensions.vscode-marketplace.roman.ayu-next
  #         vscode-extensions.vscode-marketplace.tamasfe.even-better-toml
  #       ];

  #       userSettings = {
  #         "workbench.iconTheme" = "catppuccin-macchiato";
  #         "workbench.colorTheme" = "Mayukai Semantic Mirage";
  #         "editor.fontFamily" = "'Fira Code', 'Droid Sans Mono', 'monospace', monospace";
  #         "extensions.autoCheckUpdates" = false;
  #         "update.mode" = "none";
  #         "nix.enableLanguageServer" = true;
  #         "nix.serverPath" = "nil";
  #         "nix.formatterPath" = "nixpkgs-fmt";
  #         "nix.serverSettings" = {
  #           "nil" = {
  #             "formatting" = { "command" = [ "nixpkgs-fmt" ]; };
  #           };
  #         };
  #         "files.associations" = {
  #           ".env*" = "dotenv";
  #           "*.css" = "tailwindcss";
  #         };
  #         "cursor.aipreview.enabled" = true;
  #         "workbench.activityBar.orientation" = "vertical";
  #         "git.enableCommitSigning" = false;
  #         "editor.formatOnPaste" = true;
  #         "editor.formatOnSave" = true;
  #         "editor.defaultFormatter" = "esbenp.prettier-vscode";
  #         "javascript.updateImportsOnFileMove.enabled" = "always";
  #         "[javascript]" = {
  #           "editor.defaultFormatter" = "esbenp.prettier-vscode";
  #         };
  #         "[javascriptreact]" = {
  #           "editor.defaultFormatter" = "esbenp.prettier-vscode";
  #         };
  #         "[typescript]" = {
  #           "editor.defaultFormatter" = "esbenp.prettier-vscode";
  #         };
  #         "[typescriptreact]" = {
  #           "editor.defaultFormatter" = "esbenp.prettier-vscode";
  #         };
  #         "[css]" = {
  #           "editor.defaultFormatter" = "esbenp.prettier-vscode";
  #         };
  #         "[scss]" = {
  #           "editor.defaultFormatter" = "esbenp.prettier-vscode";
  #         };
  #         "[json]" = {
  #           "editor.defaultFormatter" = "esbenp.prettier-vscode";
  #         };
  #         "[sql]" = {
  #           "editor.defaultFormatter" = "adpyke.vscode-sql-formatter";
  #         };
  #         "editor.quickSuggestions" = {
  #           "strings" = "on";
  #         };
  #         "editor.tokenColorCustomizations" = {
  #           "textMateRules" = [
  #             {
  #               "scope" = "keyword.other.dotenv";
  #               "settings" = {
  #                 "foreground" = "#FF000000";
  #               };
  #             }
  #           ];
  #         };
  #         "projectManager.projectsLocation" = "~/Projects";
  #         "typescript.updateImportsOnFileMove.enabled" = "always";
  #         "explorer.confirmDragAndDrop" = false;
  #         "prettier.experimentalTernaries" = true;
  #         "totalTypeScript.hideAllTips" = true;
  #         "totalTypeScript.hideBasicTips" = true;
  #         "dotenv.enableAutocloaking" = false;
  #         "totalTypeScript.hiddenTips" = [
  #           "passing-generics-to-types"
  #           "in-operator-narrowing"
  #           "typeof"
  #           "readonly-utility-type"
  #           "returntype-utility-type"
  #           "partial-utility-type"
  #           "omit-utility-type"
  #           "record-utility-type"
  #         ];
  #         "i18n-ally.enabledFrameworks" = ["next-intl"];
  #         "i18n-ally.keystyle" = "nested";
  #         "i18n-ally.editor.preferEditor" = true;
  #         "i18n-ally.extract.keyMaxLength" = 9999999;
  #         "i18n-ally.annotationInPlace" = false;
  #         "i18n-ally.annotations" = false;
  #         "i18n-ally.displayLanguage" = "en-AU";
  #         "i18n-ally.extract.autoDetect" = true;
  #         "i18n-ally.sourceLanguage" = "en-AU";

  #       };
  #     };
  #   };
  # };
}
