#!/usr/bin/env bash

# This script converts a standard PNG image (preferably 1024x1024) into a macOS .icns file.

set -euo pipefail

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <path-to-image.png>"
    echo "Example: $0 my-icon.png"
    exit 1
fi

INPUT_FILE="$1"
ICONSET_DIR="assets/AppIcon.iconset"
OUTPUT_ICNS="assets/AppIcon.icns"

if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: File '$INPUT_FILE' not found!"
    exit 1
fi

echo "🖼  Creating macOS AppIcon asset..."

# Ensure assets directory exists
mkdir -p "assets"

# Create a temporary .iconset directory
mkdir -p "$ICONSET_DIR"

# Generate all required icon sizes using the built-in 'sips' macOS image processing tool
sips -z 16 16     "$INPUT_FILE" --out "${ICONSET_DIR}/icon_16x16.png" > /dev/null
sips -z 32 32     "$INPUT_FILE" --out "${ICONSET_DIR}/icon_16x16@2x.png" > /dev/null
sips -z 32 32     "$INPUT_FILE" --out "${ICONSET_DIR}/icon_32x32.png" > /dev/null
sips -z 64 64     "$INPUT_FILE" --out "${ICONSET_DIR}/icon_32x32@2x.png" > /dev/null
sips -z 128 128   "$INPUT_FILE" --out "${ICONSET_DIR}/icon_128x128.png" > /dev/null
sips -z 256 256   "$INPUT_FILE" --out "${ICONSET_DIR}/icon_128x128@2x.png" > /dev/null
sips -z 256 256   "$INPUT_FILE" --out "${ICONSET_DIR}/icon_256x256.png" > /dev/null
sips -z 512 512   "$INPUT_FILE" --out "${ICONSET_DIR}/icon_256x256@2x.png" > /dev/null
sips -z 512 512   "$INPUT_FILE" --out "${ICONSET_DIR}/icon_512x512.png" > /dev/null
sips -z 1024 1024 "$INPUT_FILE" --out "${ICONSET_DIR}/icon_512x512@2x.png" > /dev/null

# Compile the .iconset into an .icns file
echo "📦 Compiling .icns file..."
iconutil -c icns "$ICONSET_DIR" -o "$OUTPUT_ICNS"

# Cleanup
rm -rf "$ICONSET_DIR"

echo "✅ Success! Saved to $OUTPUT_ICNS"
echo "You can now run ./scripts/build-release.sh to package your app with the new icon."
