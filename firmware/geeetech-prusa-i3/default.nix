let
  pkgs = import <nixpkgs> {};
in pkgs.stdenv.mkDerivation {
  name = "geeetech-prusa-i3-firmware";
  src = pkgs.fetchFromGitHub {
    owner = "MarlinFirmware";
    repo = "Marlin";
    rev = "1.1.9.1";
    hash = "sha256:1l7d05v5ck79z1rkv09qfdf8gpjirzpcdlvyfd3rncd02gzaw5mq";
  };
  patches = [
    ./dont-assume-bed-is-centred-within-limits-of-motion.patch
  ];
  phases = ["unpackPhase" "patchPhase" "configurePhase" "buildPhase" "installPhase"];
  configurePhase = ''
    export ARDUINO_USER_DIR=$NIX_BUILD_TOP/Arduino
    install -m 0644 ${./Configuration.h} Marlin/Configuration.h
  '';
  buildPhase = ''
    make -C Marlin -j ''${NIX_BUILD_CORES:-1}
    cat >flash <<EOF
    #!${pkgs.stdenv.shell}
    exec "$AVR_TOOLS_PATH"avrdude \
      -D \
      -C$ARDUINO_INSTALL_DIR/hardware/tools/avr/etc/avrdude.conf \
      -pATmega2560 \
      -P''${1:-/dev/ttyUSB0} \
      -cwiring \
      -b115200 \
      -Uflash:w:$out/Marlin.hex:i
    EOF
  '';
  installPhase = ''
    install -D -m 0644 Marlin/applet/Marlin.{elf,hex} -t $out
    install -D -m 0755 flash -t $out
  '';
  ARDUINO_INSTALL_DIR = "${pkgs.arduino-core}/share/arduino";
  AVR_TOOLS_PATH = "${pkgs.arduino-core}/share/arduino/hardware/tools/avr/bin/";  # trailing slash required
  ARDUINO_VERSION = let
    components = builtins.splitVersion pkgs.arduino-core.version;
    major = builtins.fromJSON (builtins.elemAt components 0);
    minor = builtins.fromJSON (builtins.elemAt components 1);
  in major*100 + minor;
  HARDWARE_MOTHERBOARD = 7;  # BOARD_ULTIMAKER from Marlin/boards.h.
  U8GLIB = 0;
}
