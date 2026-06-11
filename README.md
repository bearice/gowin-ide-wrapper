# Gowin IDE Wrapper

Nix flake wrappers for the Gowin IDE Linux binaries.

This repository does not vendor the Gowin IDE itself. It expects an existing Gowin
Linux install and wraps the binaries in an FHS environment with the libraries
needed by the bundled Qt applications.

## Usage

Run the IDE directly:

```sh
nix run github:bearice/gowin-ide-wrapper
```

Install into your profile:

```sh
nix profile install github:bearice/gowin-ide-wrapper
```

After installing, the wrapper exposes the Gowin `IDE/bin` executables, including
`gw_ide`, `gw_sh`, `GowinSynthesis`, `GowinModGen`, and the other IDE tools.

## Gowin Install Path

By default, the wrappers expect Gowin to be installed at:

```sh
/home/bearice/.local/gowin_linux
```

Override that at runtime with `GOWIN_ROOT`:

```sh
GOWIN_ROOT=/path/to/gowin_linux nix run github:bearice/gowin-ide-wrapper
```

For installed wrappers:

```sh
GOWIN_ROOT=/path/to/gowin_linux gw_ide
```

## Desktop Launcher

The package installs a desktop entry for `Gowin IDE` and a Gowin icon under the
standard XDG locations in the Nix output.

If your desktop environment does not refresh immediately after installation, log
out and back in or refresh your application launcher cache.
