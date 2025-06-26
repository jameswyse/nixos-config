{ pkgs }:

with pkgs; [
  _1password-cli
  act
  age
  aspell
  aspellDicts.en
  awscli2
  bash-completion
  bat
  cmatrix
  code-cursor
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
  git
  git-credential-manager
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
  libpng
  meslo-lgs-nf
  neofetch
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
  # orca-slicer
] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts)

