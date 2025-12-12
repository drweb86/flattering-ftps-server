# FTPS Flutter Server

A simple, cross-platform FTPS (FTP over TLS/SSL) file sharing server application built with Flutter. This application allows you to easily share files from your device over a secure FTP connection.

## Features

- ✅ **Cross-platform**: Works on Android, iOS, Windows, macOS, Linux, and Web
- 🔒 **Secure**: Uses FTPS (FTP over TLS/SSL) with self-signed certificates
- 👤 **Single user authentication**: Simple username/password protection
- 📁 **Full file operations**: Read, write, create, delete, rename files and directories
- 📊 **Real-time logging**: Monitor all server activities
- 🎨 **Modern UI**: Clean, intuitive Material Design interface
- ⚙️ **Configurable**: Set custom port, credentials, and shared folder

## Screenshots

[App interface showing server status, configuration, and logs]

## Prerequisites

- Flutter SDK 3.0.0 or higher
- For Android: Android SDK
- For iOS: Xcode (macOS only)
- For Windows: Visual Studio 2019 or higher with C++ tools
- For macOS: Xcode
- For Linux: Standard Linux development tools

## Installation

### Option 1: Download Pre-built Binaries

Download the latest release for your platform from the [Releases](releases) page.

### Option 2: Build from Source

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/ftps-flutter-server.git
   cd ftps-flutter-server
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   # For desktop
   flutter run -d windows  # or macos, linux
   
   # For mobile
   flutter run -d android  # or ios
   
   # For web
   flutter run -d chrome
   ```

## Building

### Automated Build Scripts

#### Linux/macOS/Unix:
```bash
chmod +x build.sh
./build.sh
```

#### Windows (PowerShell):
```powershell
.\build.ps1
```

The build scripts provide an interactive menu to select platforms or you can specify them directly:

```bash
# Build for specific platforms
./build.sh android windows web

# Or use PowerShell on Windows
.\build.ps1 -Platforms android,windows,web
```

### Manual Building

#### Android APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

#### Android App Bundle (for Google Play)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

#### iOS (macOS only)
```bash
flutter build ios --release --no-codesign
# Then open ios/Runner.xcworkspace in Xcode to sign and archive
```

#### Windows
```bash
flutter build windows --release
# Output: build/windows/runner/Release/
```

#### macOS (macOS only)
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/
```

#### Linux
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

#### Web
```bash
flutter build web --release
# Output: build/web/
```

## Usage

1. **Launch the application**

2. **Configure the server** (optional):
   - Set the port (default: 2121)
   - Set username (default: admin)
   - Set password (default: password)
   - Select a shared folder

3. **Start the server**:
   - Click the "Start Server" button
   - Note the IP address and port displayed

4. **Connect from an FTP client**:
   - Use any FTPS-compatible FTP client (FileZilla, WinSCP, etc.)
   - Connect to: `ftps://[IP_ADDRESS]:[PORT]`
   - Use the configured username and password
   - Enable "Explicit FTP over TLS" (FTPES)
   - Accept the self-signed certificate

5. **Monitor activity**:
   - Watch the real-time logs at the bottom of the screen
   - All connections and file operations are logged

## Connecting with Popular FTP Clients

### FileZilla
1. File → Site Manager → New Site
2. Protocol: FTP - File Transfer Protocol
3. Host: [Your IP Address]
4. Port: 2121 (or your configured port)
5. Encryption: Require explicit FTP over TLS
6. Logon Type: Normal
7. User: admin (or your username)
8. Password: [your password]
9. Click "Connect" and accept the certificate

### WinSCP
1. New Site
2. File protocol: FTP
3. Encryption: TLS/SSL Explicit encryption
4. Host name: [Your IP Address]
5. Port number: 2121
6. User name: admin
7. Password: [your password]
8. Click "Login" and accept the certificate

### Command Line (using curl)
```bash
# List files
curl --ftp-ssl -u admin:password -k ftps://[IP]:2121/

# Upload a file
curl --ftp-ssl -u admin:password -k -T file.txt ftps://[IP]:2121/

# Download a file
curl --ftp-ssl -u admin:password -k ftps://[IP]:2121/file.txt -o file.txt
```

## Security Considerations

⚠️ **Important Security Notes:**

- This application uses self-signed certificates which provide encryption but not authentication
- The certificate will trigger warnings in FTP clients - this is expected
- For production use, consider using properly signed certificates
- Change the default username and password immediately
- Only share the connection details with trusted users
- Consider using this only on trusted networks
- The application does not implement IP whitelisting or rate limiting

## Supported FTP Commands

- `USER`, `PASS` - Authentication
- `AUTH TLS/SSL` - Establish TLS connection
- `PBSZ`, `PROT` - Data connection protection
- `PWD`, `CWD`, `CDUP` - Directory navigation
- `LIST`, `NLST` - Directory listing
- `MKD`, `RMD` - Create/remove directories
- `RETR`, `STOR` - Download/upload files
- `DELE` - Delete files
- `RNFR`, `RNTO` - Rename files
- `SIZE`, `MDTM` - File information
- `TYPE`, `PASV` - Transfer settings
- `SYST`, `FEAT`, `OPTS` - Server information

## Troubleshooting

### Cannot connect to server
- Check firewall settings - ensure the port is open
- Verify you're on the same network as the server
- Confirm the IP address is correct
- Try pinging the server device

### Certificate errors
- This is normal with self-signed certificates
- Accept/trust the certificate in your FTP client
- Use the `-k` or `--insecure` flag with command-line tools

### Permission denied errors
- On Android 11+: Grant "Manage all files" permission
- Ensure the shared folder exists and is accessible
- Check folder permissions

### Server won't start
- Ensure the port is not already in use
- Try a different port number (e.g., 2122)
- Check if another instance is running

## Project Structure

```
ftps_flutter_app/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── screens/
│   │   └── home_screen.dart      # Main UI screen
│   └── services/
│       └── ftps_server.dart      # FTPS server implementation
├── android/                       # Android-specific files
├── ios/                          # iOS-specific files
├── windows/                      # Windows-specific files
├── macos/                        # macOS-specific files
├── linux/                        # Linux-specific files
├── web/                          # Web-specific files
├── build.sh                      # Unix build script
├── build.ps1                     # Windows build script
├── pubspec.yaml                  # Flutter dependencies
└── README.md                     # This file
```

## Dependencies

- `path_provider` - Access device storage locations
- `permission_handler` - Handle storage permissions
- `file_picker` - Select folders
- `shared_preferences` - Save settings
- `network_info_plus` - Detect IP address

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Based on the FTPS server implementation patterns from C# FtpsServerLibrary
- Built with Flutter framework
- Uses Dart's native socket and SSL/TLS capabilities

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

## Roadmap

- [ ] Multiple user support
- [ ] Custom certificate upload
- [ ] IP whitelisting
- [ ] Transfer rate limiting
- [ ] Passive port range configuration
- [ ] IPv6 support
- [ ] Active mode support
- [ ] Detailed transfer statistics
- [ ] Automatic port forwarding (UPnP)
- [ ] Dark mode theme

## Version History

### 1.0.0 (Initial Release)
- Basic FTPS server functionality
- Single user authentication
- Cross-platform support
- Real-time logging
- File and directory operations
- Self-signed certificate generation

---

Made with ❤️ using Flutter
