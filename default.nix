{
  pkgs ? import <nixpkgs> {},
  gowinRoot ? null,
  defaultGowinRoot ? "/home/bearice/.local/gowin_linux",
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
      "\${GOWIN_ROOT:-${defaultGowinRoot}}"
    else
      toString gowinRoot;

  gowinDispatcher = pkgs.writeShellScript "gowin-dispatch" ''
    if [ "$#" -lt 1 ]; then
      echo "usage: $0 <IDE/bin executable> [args...]" >&2
      exit 2
    fi

    executable="$1"
    shift

    unset QT_PLUGIN_PATH QML2_IMPORT_PATH

    export GOWINHOME="${gowinRootRuntime}/IDE"
    export QT_PLUGIN_PATH="${gowinRootRuntime}/IDE/plugins/qt"
    export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-xcb}"

    export LD_LIBRARY_PATH="${pkgs.freetype}/lib:${gowinRootRuntime}/IDE/lib:''${LD_LIBRARY_PATH:-}"
    export LD_PRELOAD="${pkgs.freetype}/lib/libfreetype.so.6''${LD_PRELOAD:+:''${LD_PRELOAD}}"

    exec "${gowinRootRuntime}/IDE/bin/$executable" "$@"
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
    nativeBuildInputs = [ pkgs.makeWrapper ];
    meta = {
      description = "FHS wrappers for Gowin IDE binaries";
      mainProgram = "gw_ide";
    };
    passthru = {
      inherit gowinExecutables fhsEnv;
    };
  }
  ''
    mkdir -p "$out/bin"

    ${lib.concatMapStringsSep "\n" (
      executable:
      ''
        makeWrapper ${fhsEnv}/bin/gowin-fhs-env "$out/bin/${executable}" \
          --add-flags ${lib.escapeShellArg executable}
      ''
    ) gowinExecutables}

    ln -s gw_ide "$out/bin/gowin-fhs"
  ''
