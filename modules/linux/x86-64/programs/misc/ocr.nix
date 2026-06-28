{ pkgs, ... }:
let
  ocr-capture = pkgs.writeShellScriptBin "ocr-capture" ''
    ${pkgs.hyprpicker}/bin/hyprpicker -r -z >/dev/null 2>&1 &
    PID=$!
    trap 'kill $PID 2>/dev/null' EXIT
    sleep 0.1

    SELECTION=$(${pkgs.slurp}/bin/slurp 2>/dev/null) || exit 0

    TEXT=$(${pkgs.grim}/bin/grim -g "$SELECTION" - | \
      ${pkgs.tesseract}/bin/tesseract stdin stdout --oem 1 --psm 6 --dpi 300 2>/dev/null) || exit 1

    [ -z "$TEXT" ] && exit 1

    printf "%s" "$TEXT" | ${pkgs.wl-clipboard}/bin/wl-copy
    ${pkgs.libnotify}/bin/notify-send -u low "OCR" "Text copied to clipboard"
  '';
in
{
  environment.systemPackages = with pkgs; [ tesseract grim ocr-capture ];
}
