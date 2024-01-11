{ pkgs }:

with pkgs; [
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
  emacs-all-the-icons-fonts
  fd
  ffmpeg
  figlet
  flyctl
  font-awesome
  git-crypt
  git-lfs
  gnupg
  hack-font
  htop
  hunspell
  iftop
  jetbrains-mono
  jq
  killall
  libfido2
  meslo-lgs-nf
  neofetch
  ngrok
  nodejs
  nodePackages.nodemon
  nodePackages.npm # globally install npm
  nodePackages.prettier
  noto-fonts
  noto-fonts-emoji
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
  zip
]
