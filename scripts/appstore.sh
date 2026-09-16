#!/bin/bash
# Build VisualAlarm for the Mac App Store: archive, sign for App Store Connect, and export a .pkg
# (or upload directly when UPLOAD=1).
#
# Prerequisites (one-time):
#   - Xcode signed in to the Apple ID of team 7JSPUB92B6 (Xcode > Settings > Accounts)
#   - The app record created in App Store Connect with bundle ID biz.yamayama.VisualAlarm
#   - -allowProvisioningUpdates lets Xcode create the "Apple Distribution" / "Mac Installer Distribution"
#     certificates and the App Store provisioning profile on first run
#
# Usage:
#   ./scripts/appstore.sh            -> build/appstore/VisualAlarm.pkg (upload with Transporter.app or Xcode Organizer)
#   UPLOAD=1 ./scripts/appstore.sh   -> uploads to App Store Connect directly
#
# Bump MARKETING_VERSION / CURRENT_PROJECT_VERSION in project.yml (then `xcodegen generate`) before each submission;
# App Store Connect rejects a build number it has already seen.

set -euo pipefail
cd "$(dirname "$0")/.."

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"
TEAM_ID="7JSPUB92B6"
BUILD_DIR="build/appstore"
DESTINATION="export"
[ "${UPLOAD:-0}" = "1" ] && DESTINATION="upload"

echo "==> 1/3 Archiving (Release, App Store signing)"
rm -rf "$BUILD_DIR"
xcodebuild -project VisualAlarm.xcodeproj -scheme VisualAlarm -configuration Release \
  archive -archivePath "$BUILD_DIR/VisualAlarm.xcarchive" -quiet -allowProvisioningUpdates \
  DEVELOPMENT_TEAM="$TEAM_ID" CODE_SIGN_STYLE=Automatic CODE_SIGN_IDENTITY="Apple Development"

echo "==> 2/3 Exporting for App Store Connect ($DESTINATION)"
cat > "$BUILD_DIR/ExportOptions.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store-connect</string>
    <key>destination</key>
    <string>$DESTINATION</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
PLIST
xcodebuild -exportArchive -archivePath "$BUILD_DIR/VisualAlarm.xcarchive" \
  -exportOptionsPlist "$BUILD_DIR/ExportOptions.plist" \
  -exportPath "$BUILD_DIR" -allowProvisioningUpdates

echo "==> 3/3 Done"
if [ "$DESTINATION" = "export" ]; then
  ls -la "$BUILD_DIR"/*.pkg
  echo "Upload the .pkg with Transporter.app (App Store Connect > TestFlight/Builds), or re-run with UPLOAD=1."
else
  echo "Uploaded. Check App Store Connect > Builds in a few minutes."
fi
