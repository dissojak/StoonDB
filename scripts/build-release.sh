#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT_DIR"

VERSION="${1:-local}"
APP_NAME="StoonDB"
APP_DIR="dist/${APP_NAME}.app"
BIN_PATH=".build/release/${APP_NAME}"
ZIP_PATH="dist/${APP_NAME}-macOS-${VERSION}.zip"
LEGACY_APP_NAME="ServerSQLPanel"

swift build -c release

# Clean old legacy-named artifacts so releases stay consistently branded.
rm -rf "dist/${LEGACY_APP_NAME}.app"
rm -f "dist/${LEGACY_APP_NAME}"*.zip "dist/${LEGACY_APP_NAME}"*.dmg

rm -rf "$APP_DIR"
mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$BIN_PATH" "$APP_DIR/Contents/MacOS/${APP_NAME}"

# Add Icon if it exists
if [ -f "assets/AppIcon.icns" ]; then
    cp "assets/AppIcon.icns" "$APP_DIR/Contents/Resources/AppIcon.icns"
fi

cat > "$APP_DIR/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon.icns</string>
    <key>CFBundleIdentifier</key>
    <string>com.dissojak.stoondb</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>${VERSION}</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>NSPrincipalClass</key>
    <string>NSApplication</string>
</dict>
</plist>
PLIST

chmod +x "$APP_DIR/Contents/MacOS/${APP_NAME}"
rm -f "$ZIP_PATH"

# Touch the app directory to invalidate Finder's icon cache
touch "$APP_DIR"

/usr/bin/ditto -c -k --sequesterRsrc --keepParent "$APP_DIR" "$ZIP_PATH"

echo "Release package created: $ZIP_PATH"

# Try to create a DMG drag-and-drop installer if the user has `create-dmg` installed via Homebrew
DMG_PATH="dist/${APP_NAME}-macOS-${VERSION}.dmg"
if command -v create-dmg &> /dev/null; then
    echo "Creating drag-and-drop macOS DMG Installer..."
    rm -f "$DMG_PATH"

    INSTRUCTIONS_FILE="dist/Install StoonDB.txt"
    cat > "$INSTRUCTIONS_FILE" <<EOF
Drag ${APP_NAME}.app to the Applications folder, then open it from Applications.
EOF
    
    # We use create-dmg to build the window with an applications symlink to mimic standard installers
    create-dmg \
      --volname "${APP_NAME} Installer" \
      --window-pos 200 120 \
      --window-size 600 400 \
      --icon-size 130 \
            --text-size 14 \
      --icon "${APP_NAME}.app" 150 190 \
      --hide-extension "${APP_NAME}.app" \
            --add-file "Install StoonDB.txt" "$INSTRUCTIONS_FILE" 300 340 \
      --app-drop-link 450 190 \
      "$DMG_PATH" \
      "$APP_DIR"

        rm -f "$INSTRUCTIONS_FILE"
    
    echo "Successfully generated Installer -> $DMG_PATH"
else
    echo "Note: Skipping .dmg generation because 'create-dmg' is not installed."
    echo "To get drag-and-drop installers locally, run: brew install create-dmg"
fi
