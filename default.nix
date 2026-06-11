{
  pkgs ? import <nixpkgs> {},
  gowinRoot ? ./.,
}:
let
  gowinRootPath = toString gowinRoot;
  gowinWrapper = pkgs.writeShellScript "gowin-wrapper" ''
    unset QT_PLUGIN_PATH QML2_IMPORT_PATH

    export GOWINHOME="${gowinRootPath}/IDE"
    export QT_PLUGIN_PATH="${gowinRootPath}/IDE/plugins/qt"
    export QT_QPA_PLATFORM="''${QT_QPA_PLATFORM:-xcb}"

    export LD_LIBRARY_PATH="${pkgs.freetype}/lib:${gowinRootPath}/IDE/lib:''${LD_LIBRARY_PATH:-}"
    export LD_PRELOAD="${pkgs.freetype}/lib/libfreetype.so.6''${LD_PRELOAD:+:''${LD_PRELOAD}}"

    exec "${gowinRootPath}/IDE/bin/gw_ide" "$@"
  '';
in
pkgs.buildFHSEnv {
  name = "gowin-fhs";
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
  runScript = "${gowinWrapper}";
}
