{ config, pkgs, agenix, secrets, ... }:

let user = "james"; in
{
  age.identityPaths = [
    "/home/${user}/.ssh/id_ed25519"
  ];

  #
  # age.secrets."ssh-key" = {
  #   symlink = false;
  #   path = "/home/${user}/.ssh/id_ed25519";
  #   file =  "${secrets}/ssh-key.age";
  #   mode = "600";
  #   owner = "${user}";
  #   group = "wheel";
  # };

}
