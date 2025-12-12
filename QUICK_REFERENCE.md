# FTPS Flutter Server - Quick Reference Card

## 🚀 Quick Commands

### Setup & Run
```bash
# First time setup
flutter pub get
./setup_dev.sh

# Run on desktop
flutter run -d windows    # Windows
flutter run -d macos      # macOS
flutter run -d linux      # Linux

# Run on mobile
flutter run -d android    # Android
flutter run -d ios        # iOS (macOS only)
```

### Building
```bash
# Interactive build menu
./build.sh               # Unix/Linux/macOS
.\build.ps1              # Windows PowerShell

# Direct platform builds
flutter build apk        # Android APK
flutter build appbundle  # Android Bundle
flutter build windows    # Windows
flutter build macos      # macOS
flutter build linux      # Linux
flutter build web        # Web
```

### Verification
```bash
./verify_project.sh      # Check project structure
flutter doctor           # Check Flutter setup
flutter analyze          # Analyze code
```

## 📋 Default Configuration

| Setting  | Default Value |
|----------|---------------|
| Port     | 2121          |
| Username | admin         |
| Password | password      |
| Protocol | FTPS (Explicit TLS) |

## 🔌 Connection Examples

### FileZilla
```
Host: [IP from app]
Protocol: FTP
Encryption: Explicit FTP over TLS
Port: 2121
User: admin
Password: password
```

### Command Line (curl)
```bash
# List files
curl --ftp-ssl -u admin:password -k ftps://IP:2121/

# Upload
curl --ftp-ssl -u admin:password -k -T file.txt ftps://IP:2121/

# Download
curl --ftp-ssl -u admin:password -k ftps://IP:2121/file.txt -o file.txt
```

### lftp
```bash
lftp -u admin,password -e "set ftp:ssl-force true; set ssl:verify-certificate no; ls; quit" IP:2121
```

## 📁 Project Structure

```
ftps_flutter_app/
├── lib/                    # Source code
│   ├── main.dart          # App entry
│   ├── screens/           # UI screens
│   └── services/          # FTPS server
├── android/               # Android config
├── ios/                   # iOS config
├── windows/               # Windows config
├── build.sh               # Build script (Unix)
├── build.ps1              # Build script (Windows)
├── README.md              # Full docs
└── QUICKSTART.md          # Quick start
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Port in use | Change to 2122 or other port |
| Can't connect | Check firewall, same network |
| Certificate error | Normal, accept in FTP client |
| Permission denied | Grant storage permissions |
| Flutter not found | Add to PATH or install |

## 📝 FTP Commands Supported

**Authentication:** USER, PASS
**Security:** AUTH, PBSZ, PROT  
**Navigation:** PWD, CWD, CDUP
**Listing:** LIST, NLST
**Files:** RETR, STOR, DELE, SIZE, MDTM
**Directories:** MKD, RMD
**Other:** RNFR, RNTO, TYPE, PASV, SYST, FEAT, OPTS, NOOP, QUIT

## 🔒 Security Notes

- ✅ TLS/SSL encryption
- ✅ Authentication required
- ✅ Path traversal protection
- ⚠️ Self-signed certificate (accept warnings)
- ⚠️ Change default password
- ⚠️ Use on trusted networks only

## 📦 Dependencies

- Flutter SDK ≥3.0.0
- Dart SDK ≥3.0.0
- path_provider ^2.1.1
- permission_handler ^11.0.1
- file_picker ^6.1.1
- shared_preferences ^2.2.2
- network_info_plus ^5.0.0

## 🎯 Build Outputs

After building, find your files in:
```
build_output/
├── android/ftps_server.apk
├── windows/[exe + dlls]
├── linux/[executable]
├── macos/[.app bundle]
└── web/[html + assets]
```

## 📞 Getting Help

1. Check README.md for detailed docs
2. Check TESTING.md for test procedures
3. Run `flutter doctor` for setup issues
4. Check PROJECT_SUMMARY.md for architecture

## ⚡ Quick Test

```bash
# 1. Start the app
flutter run -d windows

# 2. In another terminal
curl --ftp-ssl -u admin:password -k ftps://localhost:2121/

# You should see: "drwxr-xr-x ... ."
```

## 📊 Performance Tips

- Large files: Use wired connection
- Multiple clients: Ensure sufficient bandwidth
- Mobile: Keep screen on during transfers
- Background: Platform limitations apply

## 🔄 Update Process

```bash
git pull                 # Get updates
flutter pub get         # Update dependencies
flutter clean           # Clean build
./build.sh              # Rebuild
```

---

**Version:** 1.0.0 | **License:** MIT | **Platform:** Cross-platform
