{ pkgs }:
{ src }:

let
  build = import ./common.nix { inherit pkgs; } { inherit src; };
in
  build.overrideAttrs (oldAttrs: {
    name = oldAttrs.name + "-package";
    preInstallPhases = [
      "removeBeforeInstall"
    ];
    removeBeforeInstall = ''
      rm -r .dart_tool
      rm .packages
      rm .pub-cache
    '';
    installPhase = ''
      mkdir -p $out
      cp -r ./. $out
    '';
  })
