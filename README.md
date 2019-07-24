# pub2nix

## Generating nix expressions from `pubspec.yaml`

```nix
# generate.nix
{ nixpkgs ? import nix/nixpkgs.nix }:

let pkgs = nixpkgs {
  overlays = [
    (import ./nix/overlays/nixpkgs-dart.nix)
    (import ./nix/overlays/pub2nix.nix)
  ];
}; in

pkgs.pub2nix.generate
```

```sh
$ nix-shell generate.nix
```

## Installing packages

```nix
# default.nix
{ nixpkgs ? import nix/nixpkgs.nix }:

let pkgs = nixpkgs {
  overlays = [
    (import ./nix/overlays/nixpkgs-dart.nix)
    (import ./nix/overlays/pub2nix.nix)
  ];
}; in
...
pkgs.stdenv.mkDerivation {
  ...
  buildPhase = ''
    ${pkgs.pub2nix.install { projectPath = ./.; }}
    ...
  '';
  ...
}
```
