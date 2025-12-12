# Testing Guide - FTPS Flutter Server

## Manual Testing Checklist

### Basic Functionality
- [ ] App launches successfully
- [ ] UI displays correctly
- [ ] Settings are saved and loaded
- [ ] IP address is detected correctly

### Server Operations
- [ ] Server starts successfully
- [ ] Server stops cleanly
- [ ] Port configuration works
- [ ] Folder selection works
- [ ] Logs appear in real-time

### FTP Client Connection Tests

#### FileZilla
1. Open FileZilla
2. Create new site with server details
3. Set protocol to "FTP - File Transfer Protocol"
4. Set encryption to "Require explicit FTP over TLS"
5. Enter host, port, username, password
6. Connect and accept certificate
7. Verify connection succeeds

#### WinSCP
1. Open WinSCP
2. New Site
3. Set file protocol to FTP
4. Set encryption to "TLS/SSL Explicit encryption"
5. Enter connection details
6. Login and accept certificate
7. Verify connection succeeds

#### Command Line (curl)
```bash
# List directory
curl --ftp-ssl -u admin:password -k ftps://localhost:2121/

# Upload file
echo "test content" > test.txt
curl --ftp-ssl -u admin:password -k -T test.txt ftps://localhost:2121/

# Download file
curl --ftp-ssl -u admin:password -k ftps://localhost:2121/test.txt -o downloaded.txt

# Delete file
curl --ftp-ssl -u admin:password -k -Q "DELE test.txt" ftps://localhost:2121/
```

### FTP Command Tests

Connect with an FTP client and test these commands:

#### Authentication
- [ ] USER command works
- [ ] PASS command authenticates correctly
- [ ] Invalid credentials are rejected

#### TLS/SSL
- [ ] AUTH TLS establishes encryption
- [ ] PBSZ command works
- [ ] PROT P enables data encryption
- [ ] PROT C allows clear data transfer

#### Directory Navigation
- [ ] PWD shows current directory
- [ ] CWD changes directory
- [ ] CDUP goes to parent directory
- [ ] Invalid paths are rejected

#### Directory Listing
- [ ] LIST shows detailed file listing
- [ ] NLST shows simple file names
- [ ] Empty directories list correctly
- [ ] Permissions display correctly

#### File Operations
- [ ] RETR downloads files correctly
- [ ] STOR uploads files correctly
- [ ] DELE deletes files
- [ ] SIZE returns correct file size
- [ ] MDTM returns modification time

#### Directory Operations
- [ ] MKD creates directories
- [ ] RMD removes directories
- [ ] Nested directory creation works

#### Rename Operations
- [ ] RNFR marks file for rename
- [ ] RNTO completes rename
- [ ] File rename works
- [ ] Directory rename works

#### Passive Mode
- [ ] PASV returns correct address
- [ ] Data transfers work in passive mode
- [ ] Multiple transfers succeed

### Security Tests
- [ ] Self-signed certificate is generated
- [ ] TLS encryption is enforced
- [ ] Invalid credentials rejected
- [ ] Path traversal blocked (test with ../)
- [ ] Null bytes rejected in paths

### Performance Tests
- [ ] Upload large file (>100MB)
- [ ] Download large file (>100MB)
- [ ] Multiple simultaneous connections
- [ ] Rapid connect/disconnect cycles
- [ ] Directory with many files (>1000)

### Error Handling
- [ ] Invalid commands return error
- [ ] Network disconnection handled
- [ ] Full disk handled gracefully
- [ ] Permission denied handled
- [ ] File not found handled

### Platform-Specific Tests

#### Android
- [ ] Storage permissions granted
- [ ] Server runs in background
- [ ] Network permission works
- [ ] Folder picker works
- [ ] App survives rotation

#### iOS
- [ ] Local network permission granted
- [ ] Folder access works
- [ ] Background execution (limited)
- [ ] Settings persist

#### Windows
- [ ] Firewall prompt appears
- [ ] Server starts without admin
- [ ] File system access works
- [ ] Long paths supported

#### macOS
- [ ] Security prompt for network
- [ ] File access permissions
- [ ] Background execution works

#### Linux
- [ ] No permission issues
- [ ] Network binding works
- [ ] File access correct

#### Web
- [ ] Limited functionality warning
- [ ] CORS issues noted
- [ ] WebSocket alternative

## Automated Testing

### Unit Tests
```bash
flutter test
```

### Integration Tests
```bash
flutter test integration_test/
```

### Performance Tests
```bash
flutter drive --target=test_driver/perf_test.dart
```

## Test Scenarios

### Scenario 1: Basic File Sharing
1. Start server
2. Connect with FileZilla
3. Create folder
4. Upload file
5. Download file
6. Delete file
7. Disconnect

### Scenario 2: Multiple Clients
1. Start server
2. Connect client A
3. Connect client B
4. Upload from A
5. Download to B
6. Verify file integrity
7. Disconnect both

### Scenario 3: Large File Transfer
1. Start server
2. Connect client
3. Upload 500MB file
4. Monitor progress
5. Verify integrity (checksum)
6. Download back
7. Compare checksums

### Scenario 4: Error Recovery
1. Start server
2. Connect client
3. Start upload
4. Kill network
5. Verify graceful handling
6. Reconnect
7. Resume/retry transfer

## Bug Reporting

When reporting bugs, include:
- Platform and version
- Flutter version
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots/logs
- FTP client used

## Test Environment Setup

### Docker Test Server (for comparison)
```bash
docker run -d \
  -p 2122:21 \
  -p 30000-30009:30000-30009 \
  --name test_ftp \
  fauria/vsftpd
```

### Local FileZilla Server (for comparison)
Install FileZilla Server and configure for comparison testing.

## Continuous Testing

Run these regularly during development:
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Build and verify
flutter build apk --debug
```

## Known Limitations

Document any known issues or limitations:
- Web version has limited functionality
- Background execution varies by platform
- Some FTP clients may require specific settings
- IPv6 support not yet implemented
- Active mode not supported

---

Keep this checklist updated as you add features or find issues!
