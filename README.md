# pub2nix

Build pub packages with Nix.

See the `examples/` directory for usage.

## Development workflow

Enter a Nix shell and the work as normal.

```sh
$ nix-shell
[nix-shell:~/pub2nix/examples/simple]$ pub run build_runner build
```

## Production workflow

### Generating pub2nix.lock

```sh
$ nix-shell
[nix-shell:~/pub2nix/examples/simple]$ pub2nix-lock
unpacking...
...
[nix-shell:~/pub2nix/examples/simple]$ exit
```

### Building

```sh
$ nix-build
```

## How it works

We aim to build pub packages with nix using only information found in `pubspec.lock`. However, [`pubspec.lock` doesn't yet contain sha256 checksums](https://github.com/dart-lang/pub/issues/2462), and Nix needs those in order to build each package.

As a stop-gap, we require users to generate a `pub2nix.lock` file which is a copy of `pubspec.lock` with an additional `sha256` field for each package. We don't patch `pubspec.lock` directly since convenient YAML tooling changes the format in ways which Dart tooling complains about, e.g. failing to parse the Dart SDK version, as well as producing noisy diffs.

We then produce a `.pub-cache` directory using pub packages from the nix store, and call `pub get --offline`.
