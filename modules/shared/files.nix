{ pkgs, config, ... }:

# let
#  githubPublicKey = "ssh-ed25519 AAAA...";
# in
{

  # ".ssh/id_github.pub" = {
  #   text = githubPublicKey;
  # };

  ".config/neofetch.conf" = {
    text = builtins.readFile config/neofetch.conf;
  };

  ".config/starship.toml" = {
    text = builtins.readFile config/starship.toml;
  };
}
