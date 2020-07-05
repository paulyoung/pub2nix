import ../../../..

# This file would typically have contents similar to the following:

# let
#   owner = "paulyoung";
#   repo = "pub2nix";
#   rev = "2c921a46c10dc72ff33005722e4c642852ff22af";
#   sha256 = "14lcylqdmigsl7argcx1pprap6abi3znghj7469f5cif50ydw5gk";
# in
#   import (builtins.fetchTarball {
#     inherit sha256;
#     url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
#   })
