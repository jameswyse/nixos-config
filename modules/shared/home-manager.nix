{ config, pkgs, vscode-extensions, lib, ... }:

let
  name = "James Wyse";
  user = "james";
  email = "james@jameswyse.net";
in
{
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

  fish = {
    enable = true;
    interactiveShellInit = "\n        set fish_greeting\n      ";
    plugins = [{
      name = "fzf.fish";
      src = pkgs.fishPlugins.fzf-fish.src;
    }];
    shellInit =
      "\n        fish_add_path ~/.local/share/bin/\n        fzf_configure_bindings --directory=\\cf\n        fzf_configure_bindings --git_log=\\cg\n        fzf_configure_bindings --git_status=\\cs\n        fzf_configure_bindings --history=\\cr\n        fzf_configure_bindings --variables=\\cv\n        fzf_configure_bindings --processes=\\cp\n      ";
    shellAbbrs = {
      hms = "home-manager switch";
      nrs = "sudo nixos-rebuild switch";
      psl = "btm --expanded --default_widget_type=proc";
      pst = "btm --expanded --default_widget_type=proc --tree";
      sctl = "systemctl";
      sctlu = "systemctl --user";
    };
  };

  nushell = {
    enable = true;
    # configFile.source = ./.../config.nu;
    extraConfig = ''
      let carapace_completer = {|spans|
        carapace $spans.0 nushell $spans | from json
      }

      $env.config = {
        show_banner: false,
        completions: {
          case_sensitive: false # case-sensitive completions
          quick: true    # set to false to prevent auto-selecting completions
          partial: true    # set to false to prevent partial filling of the prompt
          algorithm: "fuzzy"    # prefix or fuzzy
          external: {
            # set to false to prevent nushell looking into $env.PATH to find more suggestions
            enable: true 
            # set to lower can improve completion performance at the cost of omitting some options
            max_results: 100 
            completer: $carapace_completer # check 'carapace_completer' 
          }
        }
      }

      $env.PATH = ($env.PATH | split row (char esep)
        | prepend /home/james/.apps 
        | prepend /home/james/.nix-profile/bin
        | prepend /Users/james/.nix-profile/bin 
        | prepend /nix/var/nix/profiles/default/bin 
        | prepend /run/current-system/sw/bin
        | prepend /opt/homebrew/bin
        | prepend /opt/homebrew/sbin
        | prepend /run/wrappers/bin
        | append /Applications/Postgres.app/Contents/Versions/16/bin
        | append /usr/bin/env)

      $env.HOMEBREW_PREFIX = "/opt/homebrew"
      $env.HOMEBREW_CELLAR = "/opt/homebrew/Cellar"
      $env.HOMEBREW_REPOSITORY = "/opt/homebrew/Library/.homebrew-is-managed-by-nix"

      def projects [] { (ls ~/Projects | get name | path basename) }
      def --env c [project: string@projects = ""] { cd $'~/Projects/($project)' }

      use ${pkgs.nu_scripts}/share/nu_scripts/modules/fnm/fnm.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/nix/nix.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/git/git.nu
      use ${pkgs.nu_scripts}/share/nu_scripts/modules/network/ssh.nu

    '';
    shellAliases = { };
  };

  carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  starship = {
    enable = true;
    enableNushellIntegration = true;
    settings = pkgs.lib.importTOML ../../config/starship.toml;
  };

  fzf.enable = true;

  tealdeer = {
    enable = true;
    settings = { auto_update = true; };
  };

  zoxide = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

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
      #shell = "fish";
      enabled_layouts = "fat:bias=50;full_size=1;mirrored=false";
    };
    theme = "Dracula";
  };

  vscode = {
    enable = true;
    #package = pkgs.vscodium;

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
    ];
    # ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    #      {
    #        name = "mayukaithemevsc";
    #        publisher = "GulajavaMinistudio";
    #        version = "3.2.3";
    #        sha256 = "a0f3c30a3d16e06c31766fbe2c746d80683b6211638b00b0753983a84fbb9dad";
    #      }
    #    ];

    userSettings = {
      "workbench.iconTheme" = "catppuccin-macchiato";
      "workbench.colorTheme" = "Mayukai Semantic Mirage";

      "editor.fontFamily" = "'Fira Code', 'Droid Sans Mono', 'monospace', monospace";

      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "nil";
      "nix.formatterPath" = "nixpkgs-fmt";
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = { "command" = [ "nixpkgs-fmt" ]; };
        };
      };

      "git.enableCommitSigning" = false;
      "editor.formatOnPaste" = true;
      "editor.formatOnSave" = true;
      #      "files.autoSave" = "afterDelay";
      #      "files.autoSaveDelay" = 100;
    };
  };

  tmux = {
    enable = true;
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      sensible
      yank
      prefix-highlight
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_theme 'gold'
        '';
      }
      {
        plugin = resurrect; # Used by tmux-continuum

        # Use XDG data directory
        # https://github.com/tmux-plugins/tmux-resurrect/issues/348
        extraConfig = ''
          set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
          set -g @resurrect-capture-pane-contents 'on'
          set -g @resurrect-pane-contents-area 'visible'
        '';
      }
      {
        plugin = continuum;
        extraConfig = ''
          set -g @continuum-restore 'on'
          set -g @continuum-save-interval '5' # minutes
        '';
      }
    ];
    terminal = "screen-256color";
    prefix = "C-x";
    escapeTime = 10;
    historyLimit = 50000;
    extraConfig = ''
      # Remove Vim mode delays
      set -g focus-events on

      # Enable full mouse support
      set -g mouse on

      # -----------------------------------------------------------------------------
      # Key bindings
      # -----------------------------------------------------------------------------

      # Unbind default keys
      unbind C-b
      unbind '"'
      unbind %

      # Split panes, vertical or horizontal
      bind-key x split-window -v
      bind-key v split-window -h

      # Move around panes with vim-like bindings (h,j,k,l)
      bind-key -n M-k select-pane -U
      bind-key -n M-h select-pane -L
      bind-key -n M-j select-pane -D
      bind-key -n M-l select-pane -R

      # Smart pane switching with awareness of Vim splits.
      # This is copy paste from https://github.com/christoomey/vim-tmux-navigator
      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
        | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
      bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
      bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
      bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
      bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
      tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
      if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
      if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
        "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

      bind-key -T copy-mode-vi 'C-h' select-pane -L
      bind-key -T copy-mode-vi 'C-j' select-pane -D
      bind-key -T copy-mode-vi 'C-k' select-pane -U
      bind-key -T copy-mode-vi 'C-l' select-pane -R
      bind-key -T copy-mode-vi 'C-\' select-pane -l
    '';
  };
}
