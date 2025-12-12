#!/bin/bash

# FTPS Flutter Server - Build Script for All Platforms
# This script builds the application for Android, iOS, Windows, macOS, Linux, and Web

set -e

echo "======================================"
echo "FTPS Flutter Server - Build Script"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Error: Flutter is not installed or not in PATH${NC}"
    echo "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}Flutter version:${NC}"
flutter --version
echo ""

# Get dependencies
echo -e "${YELLOW}Getting Flutter dependencies...${NC}"
flutter pub get
echo ""

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
flutter clean
echo ""

# Function to build for a specific platform
build_platform() {
    local platform=$1
    local output_dir="build_output/$platform"
    
    echo -e "${YELLOW}Building for $platform...${NC}"
    
    case $platform in
        "android")
            flutter build apk --release
            mkdir -p "$output_dir"
            cp build/app/outputs/flutter-apk/app-release.apk "$output_dir/ftps_server.apk"
            echo -e "${GREEN}✓ Android APK built successfully${NC}"
            echo -e "  Location: $output_dir/ftps_server.apk"
            ;;
            
        "android-aab")
            flutter build appbundle --release
            mkdir -p "$output_dir"
            cp build/app/outputs/bundle/release/app-release.aab "$output_dir/ftps_server.aab"
            echo -e "${GREEN}✓ Android App Bundle built successfully${NC}"
            echo -e "  Location: $output_dir/ftps_server.aab"
            ;;
            
        "ios")
            if [[ "$OSTYPE" == "darwin"* ]]; then
                flutter build ios --release --no-codesign
                echo -e "${GREEN}✓ iOS build completed (not signed)${NC}"
                echo -e "  Open ios/Runner.xcworkspace in Xcode to archive and distribute"
            else
                echo -e "${RED}✗ iOS build requires macOS${NC}"
            fi
            ;;
            
        "windows")
            flutter build windows --release
            mkdir -p "$output_dir"
            cp -r build/windows/runner/Release/* "$output_dir/"
            echo -e "${GREEN}✓ Windows build completed${NC}"
            echo -e "  Location: $output_dir/"
            ;;
            
        "macos")
            if [[ "$OSTYPE" == "darwin"* ]]; then
                flutter build macos --release
                mkdir -p "$output_dir"
                cp -r build/macos/Build/Products/Release/ftps_flutter_server.app "$output_dir/"
                echo -e "${GREEN}✓ macOS build completed${NC}"
                echo -e "  Location: $output_dir/ftps_flutter_server.app"
            else
                echo -e "${RED}✗ macOS build requires macOS${NC}"
            fi
            ;;
            
        "linux")
            flutter build linux --release
            mkdir -p "$output_dir"
            cp -r build/linux/x64/release/bundle/* "$output_dir/"
            echo -e "${GREEN}✓ Linux build completed${NC}"
            echo -e "  Location: $output_dir/"
            ;;
            
        "web")
            flutter build web --release
            mkdir -p "$output_dir"
            cp -r build/web/* "$output_dir/"
            echo -e "${GREEN}✓ Web build completed${NC}"
            echo -e "  Location: $output_dir/"
            ;;
            
        *)
            echo -e "${RED}Unknown platform: $platform${NC}"
            return 1
            ;;
    esac
    
    echo ""
}

# Main build logic
if [ $# -eq 0 ]; then
    # No arguments - show menu
    echo "Select platforms to build:"
    echo "1) Android (APK)"
    echo "2) Android (App Bundle)"
    echo "3) iOS"
    echo "4) Windows"
    echo "5) macOS"
    echo "6) Linux"
    echo "7) Web"
    echo "8) All platforms (that work on current OS)"
    echo "9) Exit"
    echo ""
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1) build_platform "android" ;;
        2) build_platform "android-aab" ;;
        3) build_platform "ios" ;;
        4) build_platform "windows" ;;
        5) build_platform "macos" ;;
        6) build_platform "linux" ;;
        7) build_platform "web" ;;
        8)
            build_platform "android"
            build_platform "web"
            
            if [[ "$OSTYPE" == "darwin"* ]]; then
                build_platform "ios"
                build_platform "macos"
            elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
                build_platform "windows"
            else
                build_platform "linux"
            fi
            ;;
        9) exit 0 ;;
        *) echo -e "${RED}Invalid choice${NC}"; exit 1 ;;
    esac
else
    # Build specified platforms
    for platform in "$@"; do
        build_platform "$platform"
    done
fi

echo ""
echo -e "${GREEN}======================================"
echo "Build process completed!"
echo "======================================${NC}"
echo ""
echo "Output location: build_output/"
