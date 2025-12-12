#!/bin/bash

# Project Verification Script
# Checks that all required files are present

echo "======================================"
echo "FTPS Flutter Server - Project Check"
echo "======================================"
echo ""

ERRORS=0
WARNINGS=0

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_file() {
    if [ -f "$1" ]; then
        echo -e "${GREEN}✓${NC} $1"
    else
        echo -e "${RED}✗${NC} $1 - MISSING"
        ((ERRORS++))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo -e "${GREEN}✓${NC} $1/"
    else
        echo -e "${YELLOW}⚠${NC} $1/ - Missing (will be auto-generated)"
        ((WARNINGS++))
    fi
}

echo "Checking core files..."
check_file "pubspec.yaml"
check_file "analysis_options.yaml"
check_file ".gitignore"
check_file "LICENSE"
echo ""

echo "Checking documentation..."
check_file "README.md"
check_file "QUICKSTART.md"
check_file "TESTING.md"
check_file "PROJECT_SUMMARY.md"
echo ""

echo "Checking build scripts..."
check_file "build.sh"
check_file "build.ps1"
check_file "setup_dev.sh"
echo ""

echo "Checking source code..."
check_file "lib/main.dart"
check_file "lib/screens/home_screen.dart"
check_file "lib/services/ftps_server.dart"
echo ""

echo "Checking platform configurations..."
check_file "android/app/build.gradle"
check_file "android/app/src/main/AndroidManifest.xml"
check_file "ios/Runner/Info.plist"
check_file "windows/runner/CMakeLists.txt"
echo ""

echo "Checking optional directories (auto-generated)..."
check_dir "android"
check_dir "ios"
check_dir "windows"
check_dir "macos"
check_dir "linux"
check_dir "web"
echo ""

# Check Flutter
echo "Checking Flutter installation..."
if command -v flutter &> /dev/null; then
    echo -e "${GREEN}✓${NC} Flutter is installed"
    flutter --version | head -n 1
else
    echo -e "${RED}✗${NC} Flutter is not installed"
    ((ERRORS++))
fi
echo ""

# Summary
echo "======================================"
echo "Verification Summary"
echo "======================================"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "You're ready to build and run the application!"
    echo ""
    echo "Next steps:"
    echo "  1. Run './setup_dev.sh' to set up development environment"
    echo "  2. Run 'flutter pub get' to fetch dependencies"
    echo "  3. Run 'flutter run' to start the app"
    echo "  4. Run './build.sh' to build release versions"
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ $WARNINGS warnings (auto-generated files missing)${NC}"
    echo ""
    echo "These directories will be created automatically by Flutter."
    echo "Run 'flutter create .' to generate them if needed."
elif [ $ERRORS -gt 0 ]; then
    echo -e "${RED}✗ $ERRORS errors found${NC}"
    if [ $WARNINGS -gt 0 ]; then
        echo -e "${YELLOW}⚠ $WARNINGS warnings${NC}"
    fi
    echo ""
    echo "Please ensure all required files are present before building."
    exit 1
fi

echo ""
