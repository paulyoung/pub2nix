let
  pkgs = import ./nix/nixpkgs.nix {
    overlays = import ./nix/overlays.nix;
  };

  default = pkgs.pub2nix.build.native {
    src = ./.;
  };

  shell = pkgs.mkShell {
    inputsFrom = [
      default
    ];
    buildInputs = [
      pkgs.pub2nix.lock
    ];
  };
in
  {
    inherit default shell;
  }
