#!/usr/bin/env bash

FILE_PATH="$1"			# Full path of the previewed file
PREVIEW_X_COORD="$2"		# x coordinate of upper left cell of preview area
PREVIEW_Y_COORD="$3"		# y coordinate of upper left cell of preview area
PREVIEW_WIDTH="$4"		# Width of the preview pane (number of fitting characters)
PREVIEW_HEIGHT="$5"		# Height of the preview pane (number of fitting characters)

TMP_FILE="$(mktemp).jpg"

mimetype=$(file --mime-type -Lb "$FILE_PATH")

kitty_clear () {
    kitty +kitten icat \
        --transfer-mode=file \
        --clear 2>/dev/null
}

kitty_show () {
    kitty +kitten icat \
        --transfer-mode=file \
        --place "${PREVIEW_WIDTH}x${PREVIEW_HEIGHT}@${PREVIEW_X_COORD}x${PREVIEW_Y_COORD}" \
        "$1" 2>/dev/null
}

case "$mimetype" in
	image/*)
        kitty_clear
        kitty_show "$FILE_PATH"
        ;;
    application/pdf)
        pdftoppm -f 1 -l 1     \
            -scale-to-x 1920            \
            -scale-to-y -1              \
            -singlefile                 \
            -jpeg -tiffcompression jpeg \
            -- "$FILE_PATH" "${TMP_FILE%.*}"
        kitty_show "$TMP_FILE"
        ;;
    video/*)
        ffmpegthumbnailer -i "$FILE_PATH" -o "$TMP_FILE" -s 0 &>/dev/null
        kitty_show "$TMP_FILE"
        ;;
	*) kitty_clear ;;
esac
