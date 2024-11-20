{ pkgs }:

with pkgs; [
  _1password
  act
  age
  aspell
  aspellDicts.en
  awscli2
  bash-completion
  bat
  cmatrix
  coreutils
  coreutils-prefixed
  cowsay
  dejavu_fonts
  dina-font
  eza
  fd
  feather-font # from overlay
  ffmpeg
  figlet
  fira-code
  fira-code-symbols
  flyctl
  fnm
  font-awesome
  gh
  git-crypt
  git-lfs
  gnupg
  hack-font
  htop
  hunspell
  iftop
  iperf
  jetbrains-mono
  jetbrains-mono
  jq
  killall
  kitty
  liberation_ttf
  libfido2
  meslo-lgs-nf
  neofetch
  nerdfonts
  ngrok
  nil # Nix LSP
  nixpkgs-fmt
  nodejs
  nodePackages.nodemon
  nodePackages.npm # globally install npm
  nodePackages.prettier
  noto-fonts
  noto-fonts-cjk-sans
  noto-fonts-emoji
  openssh
  pandoc
  python311
  python311Packages.virtualenv # globally install virtualenv
  ranger
  ripgrep
  sqlite
  tflint
  tmux
  tree
  unrar
  unzip
  wget
  yarn
  zip
]
