self: super:

{
  pub2nix = {
    generate = import ./generate.nix { inherit (self) pkgs; };
    install = import ./install.nix { inherit (self) pkgs; };
  };
}
