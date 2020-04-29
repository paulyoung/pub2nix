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

  lockFilePackages =
    pkgs.lib.optionals (builtins.hasAttr "packages" lockFile) lockFile.packages;

  # ./dart_tool/package_config.json as an attribute set.
  packageConfig = {
    configVersion = 2;
    packages = (pkgs.lib.mapAttrsToList (name: value:
      let
        nixStorePath =
          if builtins.hasAttr "sha256" value
          then pkgs.fetchzip {
            inherit (value) sha256;
            stripRoot = false;
            url = "${value.description.url}/packages/${name}/versions/${value.version}.tar.gz";
          }
          else builtins.throw ''
            pub2nix: No sha256 hash found for package "${name}". Please run pub2nix-lock.
          '';
      in
        {
          inherit name;
          rootUri = "file://${nixStorePath}";
          packageUri = "lib/";
        }
    ) lockFilePackages) ++ [{
      name = specFile.name;
      rootUri = "../";
      packageUri = "lib/";
    }];
    generator = "pub2nix";
    generatorVersion = "0.1.0";
  };

  packageConfigFile =
    pkgs.writeText "package_config.json" (builtins.toJSON packageConfig);

  # Apparently pub still expects a .pub-cache directory to exist an be populated
  # despite .dart_tool/package_config.json already containing paths to packages.
  #
  # TODO: determine if we can avoid this altogether.
  # TODO: https://github.com/dart-lang/pub/blob/6deb457048deb435009b36a4cd2d86003d107cf4/lib/src/source/hosted.dart#L441-L468
  pubCache =
    let
      step = (state: tuple:
        let
          lockPackage = tuple.fst;
          configPackage = tuple.snd;
          pubCachePathParent = pkgs.lib.concatStringsSep "/" [
            "$out"
            lockPackage.source
            (pkgs.lib.removePrefix "https://" lockPackage.description.url)
          ];
          pubCachePath = pkgs.lib.concatStringsSep "/" [
            pubCachePathParent
            "${lockPackage.description.name}-${lockPackage.version}"
          ];
          nixStorePath = pkgs.lib.removePrefix "file://" configPackage.rootUri;
        in
          state + ''
            mkdir -p ${pubCachePathParent}
            ln -s ${nixStorePath} ${pubCachePath}
          ''
      );
      packages =
        # NOTE: these lists are different lengths because the package config
        # packages list contains the entry point (the project we are building)
        # but this should be fine because the entry point is last and will be
        # dropped.
        pkgs.lib.zipLists
          (builtins.attrValues lockFile.packages)
          packageConfig.packages;

      synthesize = builtins.foldl' step "" packages;
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
      "packageConfig"
      "pubCache"
      "pubGet"
      "dartAnalyzer"
    ];
    # Some tooling still expects this file to exist
    dotPackages = ''
      touch .packages
    '';
    # Use cat to avoid permissions issues with cp and mv
    packageConfig = ''
      mkdir -p .dart_tool
      cat ${packageConfigFile} > .dart_tool/package_config.json
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
