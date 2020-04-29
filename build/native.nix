{ pkgs }:
{ binName, src }:

let
  build = import ./common.nix { inherit pkgs; } { inherit src; };
in
  build.overrideAttrs (oldAttrs: {
    inherit binName;
    name = oldAttrs.name + "-native";
    installPhase = ''
      mkdir -p $out/bin
      dart2native bin/main.dart -o $out/bin/${binName}
    '';
  })
