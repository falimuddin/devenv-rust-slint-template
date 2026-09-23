{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
let

  runtimeLibs = with pkgs; [
    stdenv.cc.cc.lib
    libGL
    libxkbcommon
    wayland
    udev
    libinput
    mesa
    fontconfig
    freetype
    libX11
    libXcursor
    libXext
    libXi
    libXrandr
    libXScrnSaver
    libXxf86vm
    systemd
  ];

  slintViewerLatest = pkgs.stdenvNoCC.mkDerivation {
    pname = "slint-viewer";
    version = "1.18.1";

    src = pkgs.fetchurl {
      url = "https://github.com/slint-ui/slint/releases/download/v1.18.1/slint-viewer-linux.tar.gz";
      hash = "sha256:86b260e661cdc24dcadaf63266b034f3281cbec542afc26545a72a986fe42a13";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    # buildInputs = commonBuildInput;
    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      libGL
      libxkbcommon
      wayland
      udev
      libinput
      mesa
      fontconfig
      freetype
      libX11
      libXcursor
      libXext
      libXi
      libXrandr
      libXScrnSaver
      libXxf86vm

    ];
    installPhase = ''
      mkdir -p $out/bin
      cp slint-viewer $out/bin/slint-viewer
      chmod +x $out/bin/slint-viewer
    '';
  };
  slintLspLatest = pkgs.stdenvNoCC.mkDerivation {
    pname = "slint-lsp";
    version = "1.18.1";

    src = pkgs.fetchurl {
      url = "https://github.com/slint-ui/slint/releases/download/v1.18.1/slint-lsp-linux.tar.gz";
      hash = "sha256:62735d2b1908ae8a33b35dcdc71fd0c713f44ef8a4a9b57e8dfa07319903eefa";
    };

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = runtimeLibs;

    installPhase = ''
      mkdir -p $out/bin
      cp slint-lsp $out/bin/slint-lsp
      chmod +x $out/bin/slint-lsp
    '';
  };
in
{
  env.GREET = "devenv";

  packages =
    with pkgs;
    [
      git
      binutils
      pkg-config
      libX11
      libxcb

      slintLspLatest
      slintViewerLatest
    ]
    ++ runtimeLibs;

  languages.rust = {
    enable = true;
    channel = "stable";
    components = [
      "cargo"
      "rustc"
      "clippy"
      "rust-analyzer"
      "rustfmt"
      "rust-src"
    ];
  };

  scripts.check.exec = ''
    if slint-lsp --version >/dev/null 2>&1 && \
       slint-viewer --version >/dev/null 2>&1 && \
       cargo --version >/dev/null 2>&1 && \
       rustc --version >/dev/null 2>&1 && \
       rust-analyzer --version >/dev/null 2>&1 && \
       rustfmt --version >/dev/null 2>&1; then
       echo -e "\033[1;36m❄️ Nix\033[0m & \033[1;33m🦀 Rust siap digunakan.\033[0m"
    else
       echo -e "\033[1;31m❌ Beberapa tools wajib belum siap atau gagal dimuat.\033[0m"
    fi
  '';

  enterShell = ''
    check
    export LD_LIBRARY_PATH="${lib.makeLibraryPath runtimeLibs}:$LD_LIBRARY_PATH"
  '';

}
