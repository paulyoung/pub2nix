{ pkgs }:

# pubspec.lock doesn't include sha256 checksums (see
# https://github.com/dart-lang/pub/issues/2462) so for now we have users
# generate them.
#
# We no longer patch the original lockfile because convenient YAML tooling
# reformats things in ways that Dart tooling doesn't like.
pkgs.writeScriptBin
  "pub2nix-lock"
  ''
    cp pubspec.lock pub2nix.lock

    ${pkgs.yq}/bin/yq \
      -r \
      '.packages[] as { description: { $name, $url }, $version } | "\($name) \($url) \($version)"' \
      pub2nix.lock |\

    while read name url version; do
      nix-prefetch-url \
        $url/packages/$name/versions/$version.tar.gz \
        --name $name-$version \
        --type sha256 \
        --unpack |\

      while read sha256; do
        cat <<< $(${pkgs.yq}/bin/yq \
          -r \
          -y \
          --arg name "$name" \
          --arg sha256 "$sha256" \
          '.packages[$name] += { "sha256": $sha256 }' \
          pub2nix.lock) > pub2nix.lock
      done
    done
  ''
