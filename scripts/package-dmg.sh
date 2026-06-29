#!/usr/bin/env bash
set -euo pipefail

APP_NAME="MacOSTodoList"
BUNDLE_ID="com.xuxiaolong-hascats.MacOSTodoList"
VERSION="0.1.0"
MINIMUM_SYSTEM_VERSION="14.0"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$ROOT_DIR/.build"
RELEASE_BINARY="$BUILD_DIR/release/$APP_NAME"
PACKAGE_DIR="$BUILD_DIR/package"
APP_PATH="$PACKAGE_DIR/$APP_NAME.app"
CONTENTS_DIR="$APP_PATH/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"
INFO_PLIST="$CONTENTS_DIR/Info.plist"
DMG_ROOT="$PACKAGE_DIR/dmg-root"
OUTPUT_DIR="$ROOT_DIR/outputs"
DMG_PATH="$OUTPUT_DIR/$APP_NAME.dmg"

rm -rf "$PACKAGE_DIR"
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR" "$DMG_ROOT" "$OUTPUT_DIR"

swift build -c release --package-path "$ROOT_DIR"

cp "$RELEASE_BINARY" "$MACOS_DIR/$APP_NAME"

cat > "$INFO_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>$APP_NAME</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$VERSION</string>
  <key>CFBundleVersion</key>
  <string>$VERSION</string>
  <key>LSMinimumSystemVersion</key>
  <string>$MINIMUM_SYSTEM_VERSION</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

plutil -lint "$INFO_PLIST" >/dev/null

codesign --force --deep --sign - "$APP_PATH"
codesign --verify --deep --strict "$APP_PATH"

cp -R "$APP_PATH" "$DMG_ROOT/"
rm -f "$DMG_PATH"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

echo "Created $DMG_PATH"
