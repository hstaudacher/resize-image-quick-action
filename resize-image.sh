#!/bin/bash
#
# Resize Image Quick Action
# Resizes images proportionally, saving alongside the original
# with dimensions appended to the filename.
#
# This script is embedded into the Automator Quick Action.
# It receives file paths as arguments ($@).

export PATH="/usr/bin:/bin:/usr/sbin:/sbin"

for f in "$@"; do
    if [ ! -f "$f" ]; then
        continue
    fi

    dir=$(dirname "$f")
    base=$(basename "$f")
    ext="${base##*.}"
    name="${base%.*}"

    # Get original dimensions using sips (built into macOS)
    orig_w=$(sips -g pixelWidth "$f" | awk '/pixelWidth/{print $2}')
    orig_h=$(sips -g pixelHeight "$f" | awk '/pixelHeight/{print $2}')

    if [ -z "$orig_w" ] || [ -z "$orig_h" ]; then
        osascript -e "display dialog \"Could not read image dimensions.\" buttons {\"OK\"} default button \"OK\" with icon stop with title \"Resize Image\""
        continue
    fi

    # Show resize dialog with two input fields
    SCRIPT_DIR="${SCRIPT_DIR:-$(dirname "$0")}"
    DIALOG="$SCRIPT_DIR/resize-dialog"
    result=$("$DIALOG" "$orig_w" "$orig_h" "$base" 2>/dev/null) || continue

    # Parse width,height from dialog output
    max_w=$(echo "$result" | cut -d',' -f1)
    max_h=$(echo "$result" | cut -d',' -f2)

    # Calculate new dimensions proportionally
    if [ -n "$max_w" ] && [ -n "$max_h" ]; then
        # Both: fit within the bounding box
        new_w=$(python3 -c "
w,h,mw,mh=$orig_w,$orig_h,$max_w,$max_h
sw,sh=mw/w,mh/h
s=min(sw,sh)
print(int(w*s))
")
        new_h=$(python3 -c "
w,h,mw,mh=$orig_w,$orig_h,$max_w,$max_h
sw,sh=mw/w,mh/h
s=min(sw,sh)
print(int(h*s))
")
    elif [ -n "$max_w" ]; then
        new_w=$max_w
        new_h=$(python3 -c "print(int($orig_h * $max_w / $orig_w))")
    else
        new_h=$max_h
        new_w=$(python3 -c "print(int($orig_w * $max_h / $orig_h))")
    fi

    output="${dir}/${name}_${new_w}x${new_h}.${ext}"

    cp "$f" "$output"
    if sips --resampleWidth "$new_w" --resampleHeight "$new_h" "$output" >/dev/null 2>&1; then
        osascript -e "display notification \"Saved: ${name}_${new_w}x${new_h}.${ext}\" with title \"Resize Image\""
    else
        osascript -e "display dialog \"Failed to resize image.\" buttons {\"OK\"} default button \"OK\" with icon stop with title \"Resize Image\""
        rm -f "$output"
    fi
done
