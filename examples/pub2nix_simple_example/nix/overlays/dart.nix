let
  owner = "paulyoung";
  repo = "nixpkgs-dart";
  rev = "346a5d1b5c2445ec5660d3c252b92367b18baaf4";
  sha256 = "0mgna3wp52jydxn3hi49v2a81pfxqclzakgbh6mwgac0lbm2pq4v";
in
  import (builtins.fetchTarball {
    inherit sha256;
    url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
  })
