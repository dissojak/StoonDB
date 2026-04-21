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
DMG_BG_PATH="dist/${APP_NAME}-dmg-background.png"
if command -v create-dmg &> /dev/null; then
    echo "Creating drag-and-drop macOS DMG Installer..."
    rm -f "$DMG_PATH"

    # Build a branded background so the installer opens with clear visual guidance.
    DMG_BG_OUT="$DMG_BG_PATH" APP_NAME="$APP_NAME" swift - <<'SWIFT'
import AppKit
import Foundation

let env = ProcessInfo.processInfo.environment
let outputPath = env["DMG_BG_OUT"] ?? "dist/StoonDB-dmg-background.png"
let appName = env["APP_NAME"] ?? "StoonDB"

let width: CGFloat = 640
let height: CGFloat = 420
let rect = NSRect(x: 0, y: 0, width: width, height: height)

let image = NSImage(size: rect.size)
image.lockFocus()

let topColor = NSColor(calibratedRed: 0.90, green: 0.95, blue: 1.00, alpha: 1.0)
let bottomColor = NSColor(calibratedRed: 0.82, green: 0.90, blue: 0.98, alpha: 1.0)
NSGradient(starting: topColor, ending: bottomColor)?.draw(in: rect, angle: 90)

let title = "Install \(appName)"
let subtitle = "Drag \(appName).app to Applications"

let titleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.boldSystemFont(ofSize: 32),
    .foregroundColor: NSColor(calibratedWhite: 0.16, alpha: 1.0)
]

let subtitleAttrs: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 18, weight: .medium),
    .foregroundColor: NSColor(calibratedWhite: 0.28, alpha: 1.0)
]

let titleSize = title.size(withAttributes: titleAttrs)
let subtitleSize = subtitle.size(withAttributes: subtitleAttrs)

title.draw(at: NSPoint(x: (width - titleSize.width) / 2, y: height - 86), withAttributes: titleAttrs)
subtitle.draw(at: NSPoint(x: (width - subtitleSize.width) / 2, y: height - 120), withAttributes: subtitleAttrs)

image.unlockFocus()

let outURL = URL(fileURLWithPath: outputPath)
if let tiff = image.tiffRepresentation,
   let rep = NSBitmapImageRep(data: tiff),
   let png = rep.representation(using: .png, properties: [:]) {
    try png.write(to: outURL)
}
SWIFT
    
    # We use create-dmg to build the window with an applications symlink to mimic standard installers
    create-dmg \
      --volname "${APP_NAME} Installer" \
        --background "$DMG_BG_PATH" \
      --window-pos 200 120 \
        --window-size 640 420 \
      --icon-size 130 \
        --text-size 14 \
        --icon "${APP_NAME}.app" 180 210 \
      --hide-extension "${APP_NAME}.app" \
        --app-drop-link 460 210 \
      "$DMG_PATH" \
      "$APP_DIR"
    
    echo "Successfully generated Installer -> $DMG_PATH"
else
    echo "Note: Skipping .dmg generation because 'create-dmg' is not installed."
    echo "To get drag-and-drop installers locally, run: brew install create-dmg"
fi
