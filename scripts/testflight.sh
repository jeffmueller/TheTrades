#!/usr/bin/env bash
#
# Archive TheTrades and upload it to TestFlight.
#
#   scripts/testflight.sh [build-number]
#
# The build number defaults to the git commit count, which climbs on every
# commit and so never collides with a build App Store Connect has already
# accepted -- the most common reason an upload is rejected outright.
#
# Credentials come from scripts/release.env (gitignored). Copy
# scripts/release.env.example to get started.

set -euo pipefail

cd "$(dirname "$0")/.."

# The Command Line Tools have no iOS SDK, so if xcode-select points at them,
# xcodebuild has to be told where the real Xcode lives.
if [[ "$(xcode-select -p)" == *CommandLineTools* ]]; then
	: "${DEVELOPER_DIR:=/Applications/Xcode.app/Contents/Developer}"
	export DEVELOPER_DIR
fi

if [[ -f scripts/release.env ]]; then
	# shellcheck source=/dev/null
	source scripts/release.env
fi

for var in ASC_KEY_ID ASC_ISSUER_ID ASC_KEY_PATH ASC_TEAM_ID; do
	if [[ -z "${!var:-}" ]]; then
		echo "error: $var is not set. See scripts/release.env.example." >&2
		exit 1
	fi
done

# xcodebuild rejects a relative key path.
ASC_KEY_PATH="$(cd "$(dirname "$ASC_KEY_PATH")" && pwd)/$(basename "$ASC_KEY_PATH")"
if [[ ! -f "$ASC_KEY_PATH" ]]; then
	echo "error: App Store Connect key not found at $ASC_KEY_PATH" >&2
	exit 1
fi

BUILD_NUMBER="${1:-$(git rev-list --count HEAD)}"
ARCHIVE_PATH="build/TheTrades.xcarchive"
EXPORT_PATH="build/export"

AUTH_ARGS=(
	-allowProvisioningUpdates
	-authenticationKeyPath "$ASC_KEY_PATH"
	-authenticationKeyID "$ASC_KEY_ID"
	-authenticationKeyIssuerID "$ASC_ISSUER_ID"
)

echo "==> Regenerating project from project.yml"
xcodegen generate

# TheTrades.xcodeproj is generated and gitignored, so the SwiftPM pins cannot
# live in their usual place inside it. They are tracked at the repo root and
# copied in here, so a release builds the exact dependency versions in
# Package.resolved.
mkdir -p TheTrades.xcodeproj/project.xcworkspace/xcshareddata/swiftpm
cp Package.resolved TheTrades.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved

echo "==> Archiving build $BUILD_NUMBER"
rm -rf "$ARCHIVE_PATH" "$EXPORT_PATH"
xcodebuild \
	-project TheTrades.xcodeproj \
	-scheme TheTrades \
	-configuration Release \
	-destination 'generic/platform=iOS' \
	-archivePath "$ARCHIVE_PATH" \
	CURRENT_PROJECT_VERSION="$BUILD_NUMBER" \
	"${AUTH_ARGS[@]}" \
	archive

# Generated rather than committed so no Team ID lives in a tracked file.
# build/ is gitignored.
EXPORT_OPTIONS="build/ExportOptions.plist"
mkdir -p build
cat > "$EXPORT_OPTIONS" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>method</key><string>app-store-connect</string>
	<key>destination</key><string>upload</string>
	<key>teamID</key><string>${ASC_TEAM_ID}</string>
	<key>signingStyle</key><string>automatic</string>
	<!-- Upload dSYMs so App Store Connect can symbolicate tester crash reports. -->
	<key>uploadSymbols</key><true/>
	<!-- Keep the build number this script passed in; do not let Xcode pick one. -->
	<key>manageAppVersionAndBuildNumber</key><false/>
</dict>
</plist>
PLIST

# -allowProvisioningUpdates lets this step create the Apple Distribution
# certificate and the App Store provisioning profile on first run.
echo "==> Exporting and uploading to TestFlight"
xcodebuild \
	-exportArchive \
	-archivePath "$ARCHIVE_PATH" \
	-exportPath "$EXPORT_PATH" \
	-exportOptionsPlist "$EXPORT_OPTIONS" \
	"${AUTH_ARGS[@]}"

echo
echo "Uploaded build $BUILD_NUMBER."
echo "App Store Connect processes it in a few minutes; internal testers can"
echo "install as soon as processing finishes."
