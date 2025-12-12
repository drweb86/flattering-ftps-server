#!/bin/bash

# Development Setup Script
# This script sets up the development environment for the FTPS Flutter Server

set -e

echo "======================================"
echo "FTPS Flutter Server - Dev Setup"
echo "======================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Flutter installation
echo -e "${YELLOW}Checking Flutter installation...${NC}"
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}Flutter is not installed!${NC}"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo -e "${GREEN}✓ Flutter is installed${NC}"
flutter --version
echo ""

# Check Flutter doctor
echo -e "${YELLOW}Running Flutter doctor...${NC}"
flutter doctor
echo ""

# Get dependencies
echo -e "${YELLOW}Getting Flutter dependencies...${NC}"
flutter pub get
echo ""

# Enable platforms
echo -e "${YELLOW}Enabling platforms...${NC}"

if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Detected macOS - enabling iOS and macOS"
elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "win32" ]]; then
    echo "Detected Windows - enabling Windows"
else
    echo "Detected Linux - enabling Linux"
fi

echo ""

# Create build output directory
echo -e "${YELLOW}Creating build output directory...${NC}"
mkdir -p build_output
echo -e "${GREEN}✓ Created build_output directory${NC}"
echo ""

# Make build script executable
echo -e "${YELLOW}Making build scripts executable...${NC}"
chmod +x build.sh 2>/dev/null || true
echo -e "${GREEN}✓ Build scripts are executable${NC}"
echo ""

# Run analyzer
echo -e "${YELLOW}Running Flutter analyzer...${NC}"
flutter analyze
echo ""

# Success message
echo -e "${GREEN}======================================"
echo "Development environment is ready!"
echo "======================================${NC}"
echo ""
echo "Next steps:"
echo "1. Run 'flutter run' to start the app in debug mode"
echo "2. Run './build.sh' to build release versions"
echo "3. Check README.md for detailed documentation"
echo ""
