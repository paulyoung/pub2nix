{ pkgs }:
{ src }:

let
  yaml = import ../yaml.nix { inherit pkgs; };

  # pubspec.yaml as an attribute set.
  #
  # TODO: file an issue about adding the name to the lock file, since that's the
  # only reason we read this.
  specFile = yaml.readYAML (src + "/pubspec.yaml");

  # pubspec.lock as an attribute set. See lock.nix for details.
  lockFile = yaml.readYAML (src + "/pub2nix.lock");

  # TODO: https://github.com/dart-lang/pub/blob/6deb457048deb435009b36a4cd2d86003d107cf4/lib/src/source/hosted.dart#L441-L468
  pubCache =
    let
      step = (state: package:
        let
          pubCachePathParent = pkgs.lib.concatStringsSep "/" [
            "$out"
            package.source
            (pkgs.lib.removePrefix "https://" package.description.url)
          ];
          pubCachePath = pkgs.lib.concatStringsSep "/" [
            pubCachePathParent
            "${package.description.name}-${package.version}"
          ];
          nixStorePath = pkgs.fetchzip {
            inherit (package) sha256;
            stripRoot = false;
            url = pkgs.lib.concatStringsSep "/" [
              package.description.url
              "packages"
              package.description.name
              "versions"
              "${package.version}.tar.gz"
            ];
          };
        in
          state + ''
            mkdir -p ${pubCachePathParent}
            ln -s ${nixStorePath} ${pubCachePath}
          ''
      );

      synthesize =
        builtins.foldl' step "" (builtins.attrValues lockFile.packages);
    in
      pkgs.runCommand "${specFile.name}_pub-cache" {} synthesize;
in
  pkgs.stdenv.mkDerivation {
    name = specFile.name;
    src = pkgs.stdenv.lib.sourceByRegex src [
      "^pubspec.yaml$"
      "^pubspec.lock$"
      "^((bin|lib|test)(\/[^\/]+)*)(\.dart)?$"
    ];
    buildInputs = [
      pkgs.dart
    ];
    preBuildPhases = [
      "dotPackages"
      "pubCache"
      "pubGet"
      "dartAnalyzer"
    ];
    # Some tooling still expects this file to exist
    dotPackages = ''
      touch .packages
    '';
    pubCache = ''
      ln -s ${pubCache} .pub-cache
      export PUB_CACHE=.pub-cache
    '';
    pubGet = ''
      pub get --no-precompile --offline
    '';
    dartAnalyzer = ''
      dartanalyzer .
    '';
    buildPhase = ''
      pub --trace run build_runner build
    '';
    doCheck = true;
    checkPhase = ''
      pub --trace run build_runner test
    '';
  }
