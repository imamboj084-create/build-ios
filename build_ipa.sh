#!/bin/bash

# Build IPA Script for Anichin iOS App
# This script builds and exports the app as IPA for Scarlet sideloading

set -e

echo "🚀 Starting Anichin iOS Build Process..."

# Configuration
PROJECT_NAME="AnichinApp"
SCHEME_NAME="AnichinApp"
CONFIGURATION="Release"
BUILD_DIR="./build"
ARCHIVE_PATH="$BUILD_DIR/$PROJECT_NAME.xcarchive"
EXPORT_PATH="$BUILD_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clean build directory
echo "🧹 Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Clean Xcode build
echo "🧹 Cleaning Xcode build..."
xcodebuild clean \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration "$CONFIGURATION"

# Resolve dependencies
echo "📦 Resolving Swift Package dependencies..."
xcodebuild -resolvePackageDependencies \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME_NAME"

# Build archive
echo "🔨 Building archive..."
xcodebuild archive \
    -project "$PROJECT_NAME.xcodeproj" \
    -scheme "$SCHEME_NAME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Archive created successfully${NC}"
else
    echo -e "${RED}❌ Archive failed${NC}"
    exit 1
fi

# Create ExportOptions.plist if not exists
if [ ! -f "ExportOptions.plist" ]; then
    echo "📝 Creating ExportOptions.plist..."
    cat > ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>ad-hoc</string>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>uploadSymbols</key>
    <false/>
    <key>signingStyle</key>
    <string>manual</string>
</dict>
</plist>
EOF
fi

# Export IPA
echo "📦 Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist ExportOptions.plist \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_REQUIRED=NO

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ IPA exported successfully${NC}"
    
    # Find and display IPA info
    IPA_FILE=$(find "$EXPORT_PATH" -name "*.ipa" | head -n 1)
    
    if [ -n "$IPA_FILE" ]; then
        IPA_SIZE=$(du -h "$IPA_FILE" | cut -f1)
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "${GREEN}🎉 Build Successful!${NC}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📱 App: $PROJECT_NAME"
        echo "📦 IPA Location: $IPA_FILE"
        echo "💾 Size: $IPA_SIZE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Next steps:"
        echo "1. Transfer IPA to your iPhone"
        echo "2. Open Scarlet app"
        echo "3. Install the IPA"
        echo "4. Trust certificate in Settings"
        echo ""
    else
        echo -e "${RED}❌ IPA file not found${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Export failed${NC}"
    exit 1
fi

# Optional: Open build folder
read -p "Open build folder? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    open "$BUILD_DIR"
fi

echo -e "${GREEN}✨ Build process completed!${NC}"
