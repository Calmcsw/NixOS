{ pkgs, ... }:
let
  fhsEnv = pkgs.buildFHSEnv {
    name = "vivado-fhs";
    targetPkgs = pkgs: with pkgs; [
      stdenv.cc.cc.lib
      zlib
      ncurses5
      glib
      libGL
      freetype
      fontconfig
      pango
      gtk2
      gtk3
      cairo
      atk
      python3
      bash
      coreutils
      unzip
      procps
      gnutar
      file
      libusb1
      openssl
      libxcrypt-legacy
      libx11
      libxext
      libxrender
      libxtst
      libxi
      libxft
      libxcb
      libxau
      libxdmcp
      libxcursor
      libxinerama
      libxfixes
      libxrandr
      libxcomposite
      libxdamage
    ];
    runScript = "bash";
  };
in
{
  environment.systemPackages = with pkgs; [
    fhsEnv

    # Run Vivado inside the FHS env; override install path with XILINX_DIR or VIVADO_VERSION
    (writeShellScriptBin "vivado" ''
      bin="''${XILINX_DIR:-$HOME/Xilinx}/Vivado/''${VIVADO_VERSION:-2024.2}/bin/vivado"
      if [ ! -f "$bin" ]; then
        echo "Vivado not found at $bin"
        echo "Run 'vivado-installer' first, or set XILINX_DIR / VIVADO_VERSION."
        exit 1
      fi
      exec ${fhsEnv}/bin/vivado-fhs -c "$bin $*"
    '')

    # Drop into the FHS shell to run the AMD installer
    (writeShellScriptBin "vivado-installer" ''
      echo "Vivado install environment ready."
      echo "Run your downloaded .bin file from here, e.g.:"
      echo "  ./FPGAs_AdaptiveSoCs_Unified_2024.2_*.bin"
      echo ""
      exec ${fhsEnv}/bin/vivado-fhs
    '')
  ];

  # USB permissions for Xilinx JTAG / Digilent programming hardware
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", MODE="0666", TAG+="uaccess"
    SUBSYSTEM=="usb", ATTRS{idVendor}=="03fd", MODE="0666", TAG+="uaccess"
  '';
}
