{ config, pkgs, lib, nix-vscode-extensions, ... }:

let
  user = "james";
  xdg_configHome  = "/home/${user}/.config";
  shared-programs = import ../shared/home-manager.nix { inherit config pkgs lib; vscode-extensions = nix-vscode-extensions.extensions.x86_64-linux; };
  shared-files = import ../shared/files.nix { inherit config pkgs; };

in
{
  home = {
    enableNixpkgsReleaseCheck = false;
    username = "${user}";
    homeDirectory = "/home/${user}";
    packages = pkgs.callPackage ./packages.nix {};
    file = shared-files // import ./files.nix { inherit user config lib pkgs; };
    stateVersion = "21.05";

    sessionVariables = {
      EDITOR = "nano";
      VISUAL = "code";
      NIXOS_OZONE_WL = "1";
      NIXPKGS_ALLOW_UNFREE = "1";
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
      XDG_SESSION_DESKTOP = "Hyprland";
      GDK_BACKEND = "wayland";
      CLUTTER_BACKEND = "wayland";
      SDL_VIDEODRIVER = "x11";
      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = lib.mkForce "qt5ct";
      QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
      QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      MOZ_ENABLE_WAYLAND = "1";
    };
  };

  # Use a dark theme
  gtk = {
    enable = true;
    font = {
      name = "Ubuntu";
      size = 12;
      package = pkgs.ubuntu_font_family;
    };
    theme = {
      name = "Tokyonight-Storm-BL";
      package = pkgs.tokyo-night-gtk;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };
    gtk3.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
    gtk4.extraConfig = {
      Settings = ''
        gtk-application-prefer-dark-theme=1
      '';
    };
  };

  # Screen lock
  services = {
    gpg-agent = {
      enable = true;
      pinentryFlavor = "qt";
    };

    screen-locker = {
      enable = true;
      inactiveInterval = 10;
      lockCmd = "${pkgs.i3lock-fancy-rapid}/bin/i3lock-fancy-rapid 10 15";
    };

    # Auto mount devices
    udiskie.enable = true;
    swayosd.enable = true;

    dunst = {
      enable = true;
      package = pkgs.dunst;
      settings = {
        global = {
          monitor = 0;
          follow = "mouse";
          border = 0;
          height = 400;
          width = 320;
          offset = "33x65";
          indicate_hidden = "yes";
          shrink = "no";
          separator_height = 0;
          padding = 32;
          horizontal_padding = 32;
          frame_width = 0;
          sort = "no";
          idle_threshold = 120;
          font = "Noto Sans";
          line_height = 4;
          markup = "full";
          format = "<b>%s</b>\n%b";
          alignment = "left";
          transparency = 10;
          show_age_threshold = 60;
          word_wrap = "yes";
          ignore_newline = "no";
          stack_duplicates = false;
          hide_duplicate_count = "yes";
          show_indicators = "no";
          icon_position = "left";
          icon_theme = "Adwaita-dark";
          sticky_history = "yes";
          history_length = 20;
          history = "ctrl+grave";
          browser = "google-chrome-stable";
          always_run_script = true;
          title = "Dunst";
          class = "Dunst";
          max_icon_size = 64;
        };
      };
    };
  };

  qt.enable = true;
  qt.platformTheme = "gtk";
  qt.style.name = "adwaita-dark";
  qt.style.package = pkgs.adwaita-qt;

  programs = shared-programs // {
    wlogout = {
      enable = true;
    };
    mpv = {
      enable = true;
      config = {
        hwdec = "auto-safe";
        
        fullscreen = true;
        fs-screen = 0;
        screen = 0;
        window-maximized = "yes";
        keep-open = "no";
        
        profile = "gpu-hq";
        ytdl-format = "bestvideo+bestaudio";
        scale = "ewa_lanczossharp";
        cscale = "ewa_lanczossharp";
        deband = true;
        
        interpolation = false;
        video-sync = "display-resample-vdrop";
        tscale = "oversample";
      };
    }; 
    waybar = {
      enable = true;
      package = pkgs.waybar;
      settings = [{
        layer = "top";
        position = "top";
        height = 50;
        spacing = 2;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/window" 
        ];

        modules-center = [
          "wlr/taskbar"
        ];

        modules-right = [
          "network"
          "pulseaudio"
          "cpu"
          "memory"
          "disk"
          "tray"
          "clock"
          "custom/notification" 
          "custom/power"
        ];

        "hyprland/workspaces" = {
          format = "{icon}";
          format-icons = {
            default = " ";
            active = " ";
            urgent = " ";
          };
          on-scroll-up = "hyprctl dispatch workspace e+1";
          on-scroll-down = "hyprctl dispatch workspace e-1";
          on-click = "activate";
        };
        "clock" = {
          format = "{: %I:%M %p}";
          tooltip = false;
        };
        "hyprland/window" = {
          max-length = 60;
          separate-outputs = false;
        };
        "memory" = {
          interval = 5;
          format = " {}%";
          tooltip = true;
        };
        "cpu" = {
          interval = 5;
          format = " {usage:2}%";
          tooltip = true;
        };
        "disk" = {
          format = "  {free}";
          tooltip = true;
        };
        "network" = {
          format-icons = [ "󰤯" "󰤟" "󰤢" "󰤥" "󰤨" ];
          format-ethernet = ": {bandwidthDownBytes} : {bandwidthUpBytes}";
          format-wifi = "{icon} {signalStrength}%";
          format-disconnected = "󰤮";
        };
        "tray" = { spacing = 12; };
        "pulseaudio" = {
          format = "{icon} {volume}% {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = " {volume}%";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [ "" "" "" ];
          };
          on-click = "pavucontrol";
        };
        "custom/notification" = {
          tooltip = false;
          format = "{icon} {}";
          format-icons = {
            notification = "<span foreground='red'><sup></sup></span>";
            none = "";
            dnd-notification = "<span foreground='red'><sup></sup></span>";
            dnd-none = "";
            inhibited-notification =
              "<span foreground='red'><sup></sup></span>";
            inhibited-none = "";
            dnd-inhibited-notification =
              "<span foreground='red'><sup></sup></span>";
            dnd-inhibited-none = "";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "task-waybar";
          escape = true;
        };
         "custom/power" = {
            "format" = " ⏻ ";
            "tooltip" = false;
            "on-click" = "wlogout --protocol layer-shell";
        };
        "wlr/taskbar" = {
            "format" = "{icon}";
            "icon-size" = 32;
            "icon-theme" = "Numix-Circle";
            "tooltip-format" = "{title}";
            "on-click" = "activate";
            "on-click-middle" = "close";
        };
      }];
      style = ''
        	* {
        		font-size: 16px;
        		font-family: Ubuntu Nerd Font, Font Awesome, sans-serif;
            		font-weight: bold;
        	}
        	window#waybar {
        		    background-color: rgba(26,27,38,0.8);
            		border-bottom: 1px solid rgba(26,27,38,0);
            		border-radius: 0px;
        		    color: #f8f8f2;
                padding-left: 20px;
                padding-right: 20px;
        	}
        	#workspaces {
        		    background: linear-gradient(180deg, #414868, #24283b);
            		margin: 5px;
            		padding: 0px 1px;
            		border-radius: 15px;
            		border: 0px;
            		font-style: normal;
            		color: #15161e;
        	}
        	#workspaces button {
            		padding: 0px 5px;
            		margin: 4px 3px;
            		border-radius: 15px;
            		border: 0px;
            		color: #15161e;
            		background-color: #1a1b26;
            		opacity: 1.0;
            		transition: all 0.3s ease-in-out;
        	}
        	#workspaces button.active {
            		color: #15161e;
            		background: #7aa2f7;
            		border-radius: 15px;
            		min-width: 40px;
            		transition: all 0.3s ease-in-out;
            		opacity: 1.0;
        	}
        	#workspaces button:hover {
            		color: #15161e;
            		background: #7aa2f7;
            		border-radius: 15px;
            		opacity: 1.0;
        	}
        	tooltip {
          		background: #1a1b26;
          		border: 1px solid #7aa2f7;
          		border-radius: 10px;
        	}
        	tooltip label {
          		color: #c0caf5;
        	}
        	#window {
            		color: #565f89;
            		background: #1a1b26;
            		border-radius: 0px 15px 50px 0px;
            		margin: 5px 5px 5px 0px;
            		padding: 2px 20px;
        	}
        	#memory {
            		color: #2ac3de;
            		background: #1a1b26;
            		border-radius: 15px 50px 15px 50px;
            		margin: 5px;
            		padding: 2px 20px;
        	}
        	#clock {
            		color: #c0caf5;
            		background: #1a1b26;
            		border-radius: 15px 50px 15px 50px;
            		margin: 5px;
            		padding: 2px 20px;
        	}
        	#cpu {
            		color: #b4f9f8;
            		background: #1a1b26;
            		border-radius: 50px 15px 50px 15px;
            		margin: 5px;
            		padding: 2px 20px;
        	}
        	#disk {
            		color: #9ece6a;
            		background: #1a1b26;
            		border-radius: 15px 50px 15px 50px;
            		margin: 5px;
            		padding: 2px 20px;
        	}
        	#network {
            		color: #ff9e64;
            		background: #1a1b26;
            		border-radius: 50px 15px 50px 15px;
            		margin: 5px;
            		padding: 2px 20px;
        	}
        	#tray {
            		color: #bb9af7;
            		background: #1a1b26;
            		border-radius: 15px 0px 0px 50px;
            		margin: 5px 0px 5px 5px;
            		padding: 2px 20px;
        	}
        	#pulseaudio {
            		color: #bb9af7;
            		background: #1a1b26;
            		border-radius: 50px 15px 50px 15px;
            		margin: 5px;
            		padding: 2px 20px;
        	}
        	#custom-notification {
            		color: #7dcfff;
            		background: #1a1b26;
            		border-radius: 15px 50px 15px 50px;
            		margin: 5px;
            		padding: 2px 20px;
        	}
      '';
    };

    gpg.enable = true;
  };

}
