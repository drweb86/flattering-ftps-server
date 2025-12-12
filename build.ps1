# FTPS Flutter Server - Build Script for Windows
# PowerShell script to build the application for various platforms

param(
    [string[]]$Platforms = @()
)

$ErrorActionPreference = "Stop"

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "FTPS Flutter Server - Build Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check if Flutter is installed
try {
    $flutterVersion = flutter --version
    Write-Host "Flutter is installed" -ForegroundColor Green
    Write-Host $flutterVersion
    Write-Host ""
} catch {
    Write-Host "Error: Flutter is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Flutter from https://flutter.dev/docs/get-started/install"
    exit 1
}

# Get dependencies
Write-Host "Getting Flutter dependencies..." -ForegroundColor Yellow
flutter pub get
Write-Host ""

# Clean previous builds
Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
flutter clean
Write-Host ""

function Build-Platform {
    param(
        [string]$Platform
    )
    
    $outputDir = "build_output\$Platform"
    
    Write-Host "Building for $Platform..." -ForegroundColor Yellow
    
    switch ($Platform) {
        "android" {
            flutter build apk --release
            New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
            Copy-Item "build\app\outputs\flutter-apk\app-release.apk" "$outputDir\ftps_server.apk"
            Write-Host "✓ Android APK built successfully" -ForegroundColor Green
            Write-Host "  Location: $outputDir\ftps_server.apk"
        }
        
        "android-aab" {
            flutter build appbundle --release
            New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
            Copy-Item "build\app\outputs\bundle\release\app-release.aab" "$outputDir\ftps_server.aab"
            Write-Host "✓ Android App Bundle built successfully" -ForegroundColor Green
            Write-Host "  Location: $outputDir\ftps_server.aab"
        }
        
        "windows" {
            flutter build windows --release
            New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
            Copy-Item "build\windows\runner\Release\*" $outputDir -Recurse -Force
            Write-Host "✓ Windows build completed" -ForegroundColor Green
            Write-Host "  Location: $outputDir\"
        }
        
        "web" {
            flutter build web --release
            New-Item -ItemType Directory -Force -Path $outputDir | Out-Null
            Copy-Item "build\web\*" $outputDir -Recurse -Force
            Write-Host "✓ Web build completed" -ForegroundColor Green
            Write-Host "  Location: $outputDir\"
        }
        
        default {
            Write-Host "Unknown platform: $Platform" -ForegroundColor Red
            return
        }
    }
    
    Write-Host ""
}

# Main build logic
if ($Platforms.Count -eq 0) {
    # No arguments - show menu
    Write-Host "Select platforms to build:"
    Write-Host "1) Android (APK)"
    Write-Host "2) Android (App Bundle)"
    Write-Host "3) Windows"
    Write-Host "4) Web"
    Write-Host "5) All platforms"
    Write-Host "6) Exit"
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-6)"
    
    switch ($choice) {
        "1" { Build-Platform "android" }
        "2" { Build-Platform "android-aab" }
        "3" { Build-Platform "windows" }
        "4" { Build-Platform "web" }
        "5" {
            Build-Platform "android"
            Build-Platform "windows"
            Build-Platform "web"
        }
        "6" { exit 0 }
        default {
            Write-Host "Invalid choice" -ForegroundColor Red
            exit 1
        }
    }
} else {
    # Build specified platforms
    foreach ($platform in $Platforms) {
        Build-Platform $platform
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "Build process completed!" -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
Write-Host "Output location: build_output\"
