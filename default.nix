{
  pkgs ? import <nixpkgs> {},
  gowinRoot ? null,
}:
let
  inherit (pkgs) lib;

  gowinExecutables = [
    "GowinModGen"
    "GowinSynthesis"
    "QtWebEngineProcess"
    "assistant"
    "floorplanner"
    "gao_analyzer"
    "gao_sh"
    "gvio_analyzer"
    "gvio_sh"
    "gw_ctrl_reg"
    "gw_fsrst_gui"
    "gw_goeye"
    "gw_ide"
    "gw_pkgviewer"
    "gw_sdceditor"
    "gw_sh"
    "hierarchy"
    "license_config_gui"
    "nlsresource"
    "rtlHierTest"
    "vlg_pp"
  ];

  gowinRootRuntime =
    if gowinRoot == null then
      "\${GOWIN_ROOT:-\${HOME:-}/.local/gowin_linux}"
    else
      toString gowinRoot;

  gowinDispatcher = pkgs.writeShellScript "gowin-dispatch" ''
    if [ "$#" -lt 1 ]; then
      echo "usage: $0 <IDE/bin executable> [args...]" >&2
      exit 2
    fi

    executable="$1"
    shift
    gowin_root="${gowinRootRuntime}"

    if [ -z "$gowin_root" ]; then
      echo "GOWIN_ROOT must point to a Gowin Linux install directory." >&2
      echo "Example: GOWIN_ROOT=/opt/gowin/gowin_linux $executable" >&2
      exit 1
    fi

    if [ ! -x "$gowin_root/IDE/bin/$executable" ]; then
      echo "Gowin executable not found or not executable: $gowin_root/IDE/bin/$executable" >&2
      echo "Install Gowin at \$HOME/.local/gowin_linux or set GOWIN_ROOT to its install directory." >&2
      exit 1
    fi

    unset QT_PLUGIN_PATH QML2_IMPORT_PATH

    export GOWINHOME="$gowin_root/IDE"
    export QT_PLUGIN_PATH="$gowin_root/IDE/plugins/qt"
    export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-xcb}"

    export LD_LIBRARY_PATH="${pkgs.freetype}/lib:$gowin_root/IDE/lib:''${LD_LIBRARY_PATH:-}"
    export LD_PRELOAD="${pkgs.freetype}/lib/libfreetype.so.6''${LD_PRELOAD:+:''${LD_PRELOAD}}"

    exec "$gowin_root/IDE/bin/$executable" "$@"
  '';

  fhsEnv = pkgs.buildFHSEnv {
    name = "gowin-fhs-env";
    targetPkgs = pkgs:
      (with pkgs; [
        alsa-lib
        dbus
        expat
        fontconfig
        freetype
        glib
        krb5
        libGL
        libx11
        libxcomposite
        libxdamage
        libxfixes
        libxkbcommon
        libxrandr
        libxtst
        libxcb
        libxcb-image
        libxcb-keysyms
        libxcb-render-util
        libxcb-util
        libxcb-wm
        nspr
        nss
        zlib
      ]);
    extraBwrapArgs = [
      "--bind-try"
      "/run/user/1000"
      "/run/user/1000"
    ];
    runScript = "${gowinDispatcher}";
  };
in
pkgs.runCommand "gowin-ide-wrapper"
  {
    nativeBuildInputs = [
      pkgs.desktop-file-utils
      pkgs.makeWrapper
    ];
    meta = {
      description = "FHS wrappers for Gowin IDE binaries";
      mainProgram = "gw_ide";
    };
    passthru = {
      inherit gowinExecutables fhsEnv;
    };
  }
  ''
    mkdir -p "$out/bin" "$out/share/applications"
    install -Dm644 ${./gowin.png} "$out/share/icons/hicolor/256x256/apps/gowin.png"

    ${lib.concatMapStringsSep "\n" (
      executable:
      ''
        makeWrapper ${fhsEnv}/bin/gowin-fhs-env "$out/bin/${executable}" \
          --add-flags ${lib.escapeShellArg executable}
      ''
    ) gowinExecutables}

    ln -s gw_ide "$out/bin/gowin-fhs"

    cat > "$out/share/applications/gowin-ide.desktop" <<EOF
    [Desktop Entry]
    Type=Application
    Name=Gowin IDE
    Comment=Gowin FPGA design environment
    Exec=$out/bin/gw_ide %F
    Icon=$out/share/icons/hicolor/256x256/apps/gowin.png
    Terminal=false
    Categories=Development;Electronics;
    StartupNotify=true
    EOF

    desktop-file-validate "$out/share/applications/gowin-ide.desktop"
  ''
