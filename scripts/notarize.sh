#!/bin/bash
# Archive, sign with Developer ID, notarize, staple, and verify VisualAlarm.
#
# Prerequisites (one-time):
#   1. A "Developer ID Application" certificate in the keychain
#      (Xcode > Settings > Accounts > Manage Certificates... > + )
#   2. notarytool credentials stored as the profile named below:
#      xcrun notarytool store-credentials "visualalarm-notary" \
#        --apple-id <apple-id> --team-id 7JSPUB92B6 --password <app-specific-password>
#
# Usage: ./scripts/notarize.sh            (or NOTARY_PROFILE=<other-profile> ./scripts/notarize.sh)
# Output: build/export/VisualAlarm.app (signed, notarized, stapled) and build/VisualAlarm.zip
#
# Day-to-day Debug builds stay ad-hoc signed (see project.yml); the Developer ID
# team and signing style are passed on the command line only for this release build;
# the export step re-signs with the Developer ID certificate.

set -euo pipefail
cd "$(dirname "$0")/.."

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
PROFILE="${NOTARY_PROFILE:-visualalarm-notary}"
TEAM_ID="7JSPUB92B6"
BUILD_DIR="build"

echo "==> 1/6 Archiving (Release)"
rm -rf "$BUILD_DIR"
xcodebuild -project VisualAlarm.xcodeproj -scheme VisualAlarm -configuration Release \
  archive -archivePath "$BUILD_DIR/VisualAlarm.xcarchive" -quiet \
  DEVELOPMENT_TEAM="$TEAM_ID" CODE_SIGN_STYLE=Automatic CODE_SIGN_IDENTITY="Apple Development"

echo "==> 2/6 Exporting with Developer ID signing"
cat > "$BUILD_DIR/ExportOptions.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>developer-id</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
PLIST
xcodebuild -exportArchive -archivePath "$BUILD_DIR/VisualAlarm.xcarchive" \
  -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
  -exportPath "$BUILD_DIR/export" -quiet

APP="$BUILD_DIR/export/VisualAlarm.app"

echo "==> 3/6 Zipping for submission"
ditto -c -k --keepParent "$APP" "$BUILD_DIR/VisualAlarm.zip"

echo "==> 4/6 Submitting to Apple notary service (waits for the result)"
xcrun notarytool submit "$BUILD_DIR/VisualAlarm.zip" \
  --keychain-profile "$PROFILE" --wait

echo "==> 5/6 Stapling the notarization ticket"
xcrun stapler staple "$APP"

echo "==> 6/6 Verifying and re-zipping the stapled app for release"
spctl -a -vv "$APP"
xcrun stapler validate "$APP"
ditto -c -k --keepParent "$APP" "$BUILD_DIR/VisualAlarm.zip"
echo "Done: $BUILD_DIR/VisualAlarm.zip"
