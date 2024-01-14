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
  btop
  cmatrix
  coreutils
  cowsay
  dejavu_fonts
  dina-font
  fd
  feather-font # from overlay
  ffmpeg
  figlet
  fira-code
  fira-code-symbols
  flyctl
  fnm
  font-awesome
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
  noto-fonts-cjk
  noto-fonts-emoji
  nu_scripts
  nushell
  openssh
  pandoc
  python39
  python39Packages.virtualenv # globally install virtualenv
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
