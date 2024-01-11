{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; }; in
shared-packages ++ [
  adwaita-qt
  appimage-run
  bc # old school calculator
  bibata-cursors
  cava # Terminal audio visualizer
  cider # Apple Music on Linux
  cliphist
  cmake
  direnv
  feh
  flameshot
  font-manager
  fontconfig
  galculator
  gnumake
  google-chrome
  grim
  home-manager
  hyprpaper
  i3lock-fancy-rapid
  inotify-tools # inotifywait, inotifywatch - For file system events
  jq
  libnotify
  libnotify
  libtool
  nwg-drawer
  papirus-icon-theme
  pavucontrol
  pavucontrol # Pulse audio controls
  pcmanfm
  pinentry-curses
  pinentry-qt
  playerctl # Control media players from command line
  postgresql
  ripgrep
  rnix-lsp # lsp-mode for nix
  rofi
  rofi-calc
  screenkey
  simplescreenrecorder
  slurp
  sqlite
  swaynotificationcenter
  swww
  tofi
  tokyo-night-gtk
  tree
  ubuntu_font_family
  unixtools.ifconfig
  unixtools.netstat
  usbutils
  vlc
  waybar
  waypaper
  wev
  wl-clipboard
  wtype
  xclip
  xdg-utils
  xdotool
  xfce.thunar
  xorg.xrandr
  xorg.xwininfo
  yad
  zathura
]
