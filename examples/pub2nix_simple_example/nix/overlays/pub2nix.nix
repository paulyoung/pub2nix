import ../../../..

# This file would typically have contents similar to the following:

# let
#   owner = "paulyoung";
#   repo = "pub2nix";
#   rev = "3493d89c189713472cbe40bcc8e9a2653775c6ca";
#   sha256 = "0y6mgjg37gn932m5abim3y0shkmp8yx4rn4wc4a2h439dkd9gfkq";
# in
#   import (builtins.fetchTarball {
#     inherit sha256;
#     url = "https://github.com/${owner}/${repo}/archive/${rev}.tar.gz";
#   })
