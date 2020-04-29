import ../../../..

# This file would typically have contents similar to the following:

# let
#   owner = "paulyoung";
#   repo = "pub2nix";
#   rev = "bfa2c2638728f8e62eb04d31bbd2e9100768d1ea";
#   sha256 = "0nsn85gwywis9w1fwmml394wh6dldznb3fq5ym7a3lvvc4cg32nz";
# in
#   import (builtins.fetchTarball {
#     inherit sha256;
#     url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
#   })
