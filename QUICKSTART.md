# Quick Start Guide - FTPS Flutter Server

## Getting Started in 5 Minutes

### 1. Install Flutter (if not already installed)

**Windows:**
```powershell
# Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
# Extract to C:\flutter
# Add C:\flutter\bin to PATH
```

**macOS:**
```bash
brew install flutter
```

**Linux:**
```bash
sudo snap install flutter --classic
```

### 2. Clone and Setup

```bash
cd ftps_flutter_app
flutter pub get
```

### 3. Run the App

**Desktop (fastest for testing):**
```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

**Mobile:**
```bash
# Connect Android device or start emulator
flutter run -d android

# iOS (macOS only, requires device or simulator)
flutter run -d ios
```

### 4. Configure and Start

1. Launch the app
2. (Optional) Change port/username/password
3. Click "Select Folder" to choose shared directory
4. Click "Start Server"
5. Note the IP address shown

### 5. Connect with FTP Client

**FileZilla Quick Connect:**
- Host: `IP_ADDRESS_FROM_APP`
- Username: `admin`
- Password: `password`
- Port: `2121`
- Protocol: FTP (explicit TLS)

**Command Line:**
```bash
curl --ftp-ssl -u admin:password -k ftps://IP_ADDRESS:2121/
```

## Building for Distribution

### Quick Build Commands

```bash
# Android APK
flutter build apk --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```

### Using Build Scripts

**Linux/Mac:**
```bash
chmod +x build.sh
./build.sh
```

**Windows:**
```powershell
.\build.ps1
```

## Common Issues

### Port Already in Use
Change the port from 2121 to 2122 or any other available port.

### Can't Connect
- Check firewall settings
- Verify same network
- Ensure server is running

### Certificate Warning
Normal with self-signed certificates. Accept/trust the certificate in your FTP client.

## Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Customize settings in the app
- Share your IP:Port with trusted users
- Monitor the logs for connections

---

Need help? Open an issue on GitHub!
