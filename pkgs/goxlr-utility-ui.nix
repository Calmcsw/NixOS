{ lib
, stdenv
, fetchFromGitHub
, rustPlatform
, pkg-config
, clang
, wrapGAppsHook3
, glib
, cairo
, gdk-pixbuf
, pango
, gtk3
, webkitgtk_4_1
, libsoup_3
, gst_all_1
, openssl
, goxlr-utility
}:

rustPlatform.buildRustPackage rec {
  pname = "goxlr-utility-ui";
  version = "0.0.6";

  src = fetchFromGitHub {
    owner = "GoXLR-on-Linux";
    repo = "goxlr-utility-ui-wrapper-app";
    rev = "v${version}";
    hash = "sha256-D3BlR1XC+bLC+rxgpCPTKxJzXW2Fi/CPGSS0NLRxxj8=";
  };

  # Cargo.toml is in src-tauri directory
  sourceRoot = "${src.name}/src-tauri";

  cargoHash = "sha256-lgccZwY3QV6zxjh3cihMpIVHgSd/CcIaXbDfFH1nO+4=";

  nativeBuildInputs = [
    pkg-config
    clang
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    cairo
    gdk-pixbuf
    pango
    gtk3
    webkitgtk_4_1
    libsoup_3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    openssl
  ];

  propagatedBuildInputs = [
    goxlr-utility
  ];

  LIBCLANG_PATH = "${clang.cc.lib}/lib";

  postInstall = ''
  install -Dm644 ../ci/resources/${pname}.desktop $out/share/applications/${pname}.desktop
  install -Dm644 ../LICENSE $out/share/licenses/${pname}/LICENSE
  '';

  meta = with lib; {
    description = "A UI Wrapper for the GoXLR Utility";
    homepage = "https://github.com/GoXLR-on-Linux/goxlr-utility-ui-wrapper-app";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = pname;
  };
}
