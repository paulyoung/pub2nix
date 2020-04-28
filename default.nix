self: super:

{
  pub2nix = {
    build = {
      native = import ./build/native.nix { inherit (self) pkgs; };
      package = import ./build/package.nix { inherit (self) pkgs; };
    };
    lock = import ./lock.nix { inherit (self) pkgs; };
  };
}
