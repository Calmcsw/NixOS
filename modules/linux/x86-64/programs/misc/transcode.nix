{ pkgs, ... }:
let
  transcode = pkgs.writeShellScriptBin "transcode" ''
    set -euo pipefail

    FILE=$(${pkgs.yad}/bin/yad --file --center \
      --title="Select file to transcode" \
      --file-filter="Media|*.jpg *.jpeg *.png *.webp *.heic *.avif *.mp4 *.mov *.mkv *.webm *.avi *.gif" \
      2>/dev/null) || exit 0

    [[ -z $FILE || ! -f $FILE ]] && exit 1

    MIME=$(file -b --mime-type "$FILE")
    case "$MIME" in
      image/*) TYPE=picture ;;
      video/*) TYPE=video ;;
      *)
        ${pkgs.libnotify}/bin/notify-send "Transcode" "Unsupported file type: $MIME"
        exit 1
        ;;
    esac

    if [[ $TYPE == "picture" ]]; then
      FORMAT=$(${pkgs.yad}/bin/yad --list --center --no-headers \
        --title="Output format" --column="Format" \
        "jpg" "png" \
        --print-column=1 --separator="" \
        --button="Cancel:1" --button="Select:0" 2>/dev/null) || exit 0
      RESOLUTION=$(${pkgs.yad}/bin/yad --list --center --no-headers \
        --title="Output resolution" --column="Size" --column="Max width" \
        "high" "3160 px max" "medium" "2160 px max" "low" "1080 px max" \
        --print-column=1 --separator="" \
        --button="Cancel:1" --button="Select:0" 2>/dev/null) || exit 0
    else
      FORMAT=$(${pkgs.yad}/bin/yad --list --center --no-headers \
        --title="Output format" --column="Format" \
        "mp4" "gif" \
        --print-column=1 --separator="" \
        --button="Cancel:1" --button="Select:0" 2>/dev/null) || exit 0
      RESOLUTION=$(${pkgs.yad}/bin/yad --list --center --no-headers \
        --title="Output resolution" --column="Size" \
        "4k" "1080p" "720p" \
        --print-column=1 --separator="" \
        --button="Cancel:1" --button="Select:0" 2>/dev/null) || exit 0
    fi

    [[ -z $FORMAT || -z $RESOLUTION ]] && exit 1

    DIR=$(dirname -- "$FILE")
    STEM=$(basename -- "''${FILE%.*}")
    OUTPUT="$DIR/''${STEM}-''${RESOLUTION}.''${FORMAT}"

    if [[ $TYPE == "picture" ]]; then
      case "$RESOLUTION" in
        high)   RESIZE='3160x>' ;;
        medium) RESIZE='2160x>' ;;
        low)    RESIZE='1080x>' ;;
      esac
      ${pkgs.imagemagick}/bin/convert "$FILE" -resize "$RESIZE" \
        $([[ $FORMAT == "jpg" ]] && echo "-quality 85") -strip "$OUTPUT"
    else
      case "$RESOLUTION" in
        4k)    SCALE='scale=-2:2160' ;;
        1080p) SCALE='scale=-2:1080' ;;
        720p)  SCALE='scale=-2:720' ;;
      esac
      ${pkgs.libnotify}/bin/notify-send -u low "Transcoding…" "$(basename "$FILE") → $FORMAT ($RESOLUTION)"
      case "$FORMAT" in
        mp4)
          if [[ $RESOLUTION == "4k" ]]; then
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$FILE" -vf "$SCALE" -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k -y "$OUTPUT"
          else
            ${pkgs.ffmpeg}/bin/ffmpeg -i "$FILE" -vf "$SCALE" -c:v libx264 -preset fast -crf 23 -c:a copy -y "$OUTPUT"
          fi
          ;;
        gif)
          ${pkgs.ffmpeg}/bin/ffmpeg -i "$FILE" \
            -vf "fps=10,$SCALE:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -y "$OUTPUT"
          ;;
      esac
    fi

    printf '%s' "file://$(realpath -- "$OUTPUT")" | ${pkgs.wl-clipboard}/bin/wl-copy --type text/uri-list
    ${pkgs.libnotify}/bin/notify-send -u low "Transcoded" "$(basename "$OUTPUT") — copied to clipboard"
  '';
in
{
  environment.systemPackages = with pkgs; [ ffmpeg imagemagick transcode ];
}
