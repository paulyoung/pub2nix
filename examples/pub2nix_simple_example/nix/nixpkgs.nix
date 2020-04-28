let
  owner = "NixOS";
  repo = "nixpkgs";
  rev = "20.03-beta";
  sha256 = "04g53i02hrdfa6kcla5h1q3j50mx39fchva7z7l32pk699nla4hi";
in
  import (builtins.fetchTarball {
    inherit sha256;
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
  })
