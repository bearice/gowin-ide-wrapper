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

By default, the wrappers look for Gowin at:

```sh
$HOME/.local/gowin_linux
```

Set `GOWIN_ROOT` to override that. It should point to the directory that
contains `IDE/` and `Programmer/`:

```sh
GOWIN_ROOT=/path/to/gowin_linux nix run github:bearice/gowin-ide-wrapper
```

For installed wrappers:

```sh
GOWIN_ROOT=/path/to/gowin_linux gw_ide
```

If neither `GOWIN_ROOT` nor the default path contains the requested executable,
the wrapper exits with a clear error.

## Desktop Launcher

The package installs a desktop entry for `Gowin IDE` and a Gowin icon under the
standard XDG locations in the Nix output.

If your desktop environment does not refresh immediately after installation, log
out and back in or refresh your application launcher cache.
