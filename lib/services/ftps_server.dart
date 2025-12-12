import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as path;

class FtpsServer {
  ServerSocket? _serverSocket;
  SecurityContext? _securityContext;
  final int port;
  final String username;
  final String password;
  final String sharedFolder;
  final List<Socket> _clients = [];
  bool _isRunning = false;
  final StreamController<String> _logController = StreamController<String>.broadcast();

  FtpsServer({
    required this.port,
    required this.username,
    required this.password,
    required this.sharedFolder,
  });

  Stream<String> get logStream => _logController.stream;
  bool get isRunning => _isRunning;

  void _log(String message) {
    final timestamp = DateTime.now().toString().substring(0, 19);
    final logMessage = '[$timestamp] $message';
    print(logMessage);
    _logController.add(logMessage);
  }

  Future<void> start() async {
    if (_isRunning) {
      _log('Server is already running');
      return;
    }

    try {
      // Create shared folder if it doesn't exist
      final dir = Directory(sharedFolder);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        _log('Created shared folder: $sharedFolder');
      }

      // Create self-signed certificate
      _securityContext = await _createSelfSignedCertificate();

      // Start server
      _serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port);
      _isRunning = true;
      
      _log('FTPS Server started on port $port');
      _log('Shared folder: $sharedFolder');
      _log('Username: $username');

      _serverSocket!.listen(_handleClient);
    } catch (e) {
      _log('Failed to start server: $e');
      rethrow;
    }
  }

  Future<void> stop() async {
    if (!_isRunning) return;

    _isRunning = false;
    
    for (var client in _clients) {
      try {
        client.destroy();
      } catch (_) {}
    }
    _clients.clear();

    await _serverSocket?.close();
    _serverSocket = null;
    
    _log('Server stopped');
  }

  Future<SecurityContext> _createSelfSignedCertificate() async {
    final context = SecurityContext();
    
    // For simplicity, using a bundled certificate
    // In production, generate proper certificates
    const certPem = '''-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAKL0UG+mRKSzMA0GCSqGSIb3DQEBCwUAMEUxCzAJBgNV
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVQQKDBhJbnRlcm5ldCBX
aWRnaXRzIFB0eSBMdGQwHhcNMjQwMTAxMDAwMDAwWhcNMjUwMTAxMDAwMDAwWjBF
MQswCQYDVQQGEwJBVTETMBEGA1UECAwKU29tZS1TdGF0ZTEhMB8GA1UECgwYSW50
ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIB
CgKCAQEAw8VKvqNZvl0pN3xUJ0FzN3p1EhvU5PvKJ6cR7lGPFmIgZ5qJ7p5lR0zz
4h3VHLl9dV7pP1hC3qV8B8nKvJdR5vF3pK6VqN8L0VpR6L7mR8J9qP3hP5K8L0R6
V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7m
R8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7q
K5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3h
P5K8L0R6V9mN8J7qK5hR6QIDAQABo1AwTjAdBgNVHQ4EFgQU8L0R6V9mN8J7qK5h
R6N8L0VpR6IwHwYDVR0jBBgwFoAU8L0R6V9mN8J7qK5hR6N8L0VpR6IwDAYDVR0T
BAUwAwEB/zANBgkqhkiG9w0BAQsFAAOCAQEAqN8L0VpR6L7mR8J9qP3hP5K8L0R6
V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7m
R8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7q
K5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3h
P5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6Q==
-----END CERTIFICATE-----''';

    const keyPem = '''-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDDxUq+o1m+XSk3
fFQnQXM3enUSG9Tk+8onpxHuUY8WYiBnmonunmVHTPPiHdUcuX11Xuk/WELepXwH
ycq8l1Hm8XekrpWo3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3wnuormFHo3wvRWlHo
vuZHwn2o/eE/krwvRHpX2Y3wnuormFHo3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3w
nuormFHo3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3wnuormFHo3wvRWlHovuZHwn2o
/eE/krwvRHpX2Y3wnuormFHo3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3wnuormFHo
3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3wnuormFHpAgMBAAECggEAQN8L0VpR6L7m
R8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7q
K5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3h
P5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L
0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6
V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7m
R8J9qP3hP5K8L0R6V9mN8J7qK5hR6QKBgQD3hP5K8L0R6V9mN8J7qK5hR6N8L0Vp
R6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9m
N8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J
9qP3hP5K8L0R6V9mN8J7qK5hR6QKBgQDKvJdR5vF3pK6VqN8L0VpR6L7mR8J9qP3h
P5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L
0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6
V9mN8J7qK5hR6N8L0VpR6L7mR8J9qQKBgE/krwvRHpX2Y3wnuormFHo3wvRWlHo
vuZHwn2o/eE/krwvRHpX2Y3wnuormFHo3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3w
nuormFHo3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3wnuormFHo3wvRWlHovuZHwn2o
/eE/krwvRHpX2Y3wnuormFHo3wvRAoGBAKVqN8L0VpR6L7mR8J9qP3hP5K8L0R6
V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7m
R8J9qP3hP5K8L0R6V9mN8J7qK5hR6N8L0VpR6L7mR8J9qP3hP5K8L0R6V9mN8J7q
K5hR6N8L0VpR6L7mR8J9qP3hAoGAFHo3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3w
nuormFHo3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3wnuormFHo3wvRWlHovuZHwn2o
/eE/krwvRHpX2Y3wnuormFHo3wvRWlHovuZHwn2o/eE/krwvRHpX2Y3wnuormFHo
3wvRWlHovuZHwn2o/eE=
-----END PRIVATE KEY-----''';

    context.useCertificateChainBytes(certPem.codeUnits);
    context.usePrivateKeyBytes(keyPem.codeUnits);
    
    return context;
  }

  void _handleClient(Socket client) {
    _clients.add(client);
    final address = client.remoteAddress.address;
    _log('Client connected: $address');

    final session = ClientSession(
      client: client,
      username: username,
      password: password,
      sharedFolder: sharedFolder,
      securityContext: _securityContext,
      onLog: _log,
    );

    session.handle().then((_) {
      _clients.remove(client);
      _log('Client disconnected: $address');
    }).catchError((e) {
      _log('Client error: $e');
      _clients.remove(client);
    });
  }

  void dispose() {
    _logController.close();
  }
}

class ClientSession {
  final Socket client;
  final String username;
  final String password;
  final String sharedFolder;
  final SecurityContext? securityContext;
  final Function(String) onLog;

  SecureSocket? _secureSocket;
  Socket? _currentSocket;
  bool _authenticated = false;
  String? _currentUser;
  String _currentDir = '/';
  String _transferMode = 'I';
  ServerSocket? _dataListener;
  String? _renameFrom;

  ClientSession({
    required this.client,
    required this.username,
    required this.password,
    required this.sharedFolder,
    required this.securityContext,
    required this.onLog,
  }) {
    _currentSocket = client;
  }

  Future<void> handle() async {
    try {
      await _sendResponse(220, 'FTPS Server Ready');

      await for (var data in client) {
        final commands = String.fromCharCodes(data).trim().split('\r\n');
        
        for (var command in commands) {
          if (command.isEmpty) continue;
          
          final parts = command.split(' ');
          final cmd = parts[0].toUpperCase();
          final arg = parts.length > 1 ? parts.sublist(1).join(' ') : '';

          final logCmd = cmd == 'PASS' ? 'PASS ****' : command;
          onLog('>> $logCmd');

          await _processCommand(cmd, arg);

          if (cmd == 'QUIT') return;
        }
      }
    } catch (e) {
      onLog('Session error: $e');
    } finally {
      client.destroy();
      _dataListener?.close();
    }
  }

  Future<void> _processCommand(String cmd, String arg) async {
    try {
      switch (cmd) {
        case 'USER':
          _currentUser = arg;
          await _sendResponse(331, 'Password required');
          break;

        case 'PASS':
          if (_currentUser == username && arg == password) {
            _authenticated = true;
            await _sendResponse(230, 'User logged in');
          } else {
            await _sendResponse(530, 'Login incorrect');
          }
          break;

        case 'AUTH':
          if (arg.toUpperCase() == 'TLS' || arg.toUpperCase() == 'SSL') {
            await _sendResponse(234, 'AUTH command ok. Expecting TLS Negotiation.');
            if (securityContext != null) {
              _secureSocket = await SecureSocket.secure(
                client,
                context: securityContext!,
                onBadCertificate: (_) => true,
              );
              _currentSocket = _secureSocket!;
              onLog('TLS enabled');
            }
          } else {
            await _sendResponse(504, 'AUTH type not supported');
          }
          break;

        case 'PBSZ':
          await _sendResponse(200, 'PBSZ=0');
          break;

        case 'PROT':
          if (arg.toUpperCase() == 'P' || arg.toUpperCase() == 'C') {
            await _sendResponse(200, 'Protection level set');
          } else {
            await _sendResponse(504, 'PROT type not supported');
          }
          break;

        case 'PWD':
        case 'XPWD':
          if (!_authenticated) {
            await _sendResponse(530, 'Not logged in');
            return;
          }
          await _sendResponse(257, '"$_currentDir" is current directory');
          break;

        case 'CWD':
        case 'XCWD':
          await _handleCwd(arg);
          break;

        case 'CDUP':
        case 'XCUP':
          await _handleCdup();
          break;

        case 'TYPE':
          _transferMode = arg.toUpperCase();
          await _sendResponse(200, 'Type set to $_transferMode');
          break;

        case 'PASV':
          await _handlePasv();
          break;

        case 'LIST':
          await _handleList(arg);
          break;

        case 'NLST':
          await _handleNlst(arg);
          break;

        case 'RETR':
          await _handleRetr(arg);
          break;

        case 'STOR':
          await _handleStor(arg);
          break;

        case 'DELE':
          await _handleDele(arg);
          break;

        case 'MKD':
        case 'XMKD':
          await _handleMkd(arg);
          break;

        case 'RMD':
        case 'XRMD':
          await _handleRmd(arg);
          break;

        case 'RNFR':
          await _handleRnfr(arg);
          break;

        case 'RNTO':
          await _handleRnto(arg);
          break;

        case 'SIZE':
          await _handleSize(arg);
          break;

        case 'MDTM':
          await _handleMdtm(arg);
          break;

        case 'SYST':
          await _sendResponse(215, 'UNIX Type: L8');
          break;

        case 'FEAT':
          await _sendResponse(211, 'Features:\r\n AUTH TLS\r\n PBSZ\r\n PROT\r\n SIZE\r\n MDTM\r\n UTF8\r\n211 End');
          break;

        case 'OPTS':
          await _sendResponse(200, 'OK');
          break;

        case 'NOOP':
          await _sendResponse(200, 'OK');
          break;

        case 'QUIT':
          await _sendResponse(221, 'Goodbye');
          break;

        default:
          await _sendResponse(502, 'Command not implemented');
      }
    } catch (e) {
      onLog('Command error: $e');
      await _sendResponse(550, 'Error: $e');
    }
  }

  Future<void> _handleCwd(String dir) async {
    if (!_authenticated) {
      await _sendResponse(530, 'Not logged in');
      return;
    }

    final newPath = _resolvePath(dir);
    final fullPath = path.join(sharedFolder, newPath.substring(1));

    if (await Directory(fullPath).exists()) {
      _currentDir = newPath;
      await _sendResponse(250, 'Directory changed');
    } else {
      await _sendResponse(550, 'Directory not found');
    }
  }

  Future<void> _handleCdup() async {
    if (!_authenticated) {
      await _sendResponse(530, 'Not logged in');
      return;
    }

    if (_currentDir != '/') {
      _currentDir = path.dirname(_currentDir);
      if (_currentDir.isEmpty) _currentDir = '/';
    }
    await _sendResponse(250, 'Directory changed');
  }

  Future<void> _handlePasv() async {
    if (!_authenticated) {
      await _sendResponse(530, 'Not logged in');
      return;
    }

    _dataListener = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final port = _dataListener!.port;
    
    final localIp = client.address.address;
    final ipParts = localIp.split('.');
    
    final response = 'Entering Passive Mode (${ipParts.join(',')},${port ~/ 256},${port % 256})';
    await _sendResponse(227, response);
  }

  Future<void> _handleList(String arg) async {
    if (!_authenticated || _dataListener == null) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final dataClient = await _dataListener!.first;
    final targetPath = arg.isEmpty ? _currentDir : _resolvePath(arg);
    final fullPath = path.join(sharedFolder, targetPath.substring(1));

    await _sendResponse(150, 'Opening data connection');

    try {
      if (await Directory(fullPath).exists()) {
        final dir = Directory(fullPath);
        final entries = await dir.list().toList();

        for (var entry in entries) {
          final stat = await entry.stat();
          final isDir = entry is Directory;
          final perms = isDir ? 'drwxr-xr-x' : '-rw-r--r--';
          final size = isDir ? '0' : stat.size.toString().padLeft(15);
          final modified = '${stat.modified.month.toString().padLeft(2, '0')} ${stat.modified.day.toString().padLeft(2, '0')} ${stat.modified.hour.toString().padLeft(2, '0')}:${stat.modified.minute.toString().padLeft(2, '0')}';
          final name = path.basename(entry.path);
          
          final line = '$perms 1 owner group $size $modified $name\r\n';
          dataClient.write(line);
        }
      }
      
      await dataClient.flush();
      dataClient.destroy();
      await _sendResponse(226, 'Transfer complete');
    } catch (e) {
      onLog('List error: $e');
      await _sendResponse(550, 'List failed');
    } finally {
      _dataListener?.close();
      _dataListener = null;
    }
  }

  Future<void> _handleNlst(String arg) async {
    if (!_authenticated || _dataListener == null) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final dataClient = await _dataListener!.first;
    final targetPath = arg.isEmpty ? _currentDir : _resolvePath(arg);
    final fullPath = path.join(sharedFolder, targetPath.substring(1));

    await _sendResponse(150, 'Opening data connection');

    try {
      if (await Directory(fullPath).exists()) {
        final dir = Directory(fullPath);
        final entries = await dir.list().toList();

        for (var entry in entries) {
          final name = path.basename(entry.path);
          dataClient.write('$name\r\n');
        }
      }
      
      await dataClient.flush();
      dataClient.destroy();
      await _sendResponse(226, 'Transfer complete');
    } catch (e) {
      await _sendResponse(550, 'List failed');
    } finally {
      _dataListener?.close();
      _dataListener = null;
    }
  }

  Future<void> _handleRetr(String filename) async {
    if (!_authenticated || _dataListener == null) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final filePath = _resolvePath(filename);
    final fullPath = path.join(sharedFolder, filePath.substring(1));

    if (!await File(fullPath).exists()) {
      await _sendResponse(550, 'File not found');
      return;
    }

    final dataClient = await _dataListener!.first;
    await _sendResponse(150, 'Opening data connection');

    try {
      final file = File(fullPath);
      final bytes = await file.readAsBytes();
      dataClient.add(bytes);
      await dataClient.flush();
      dataClient.destroy();
      await _sendResponse(226, 'Transfer complete');
    } catch (e) {
      await _sendResponse(550, 'Transfer failed');
    } finally {
      _dataListener?.close();
      _dataListener = null;
    }
  }

  Future<void> _handleStor(String filename) async {
    if (!_authenticated || _dataListener == null) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final filePath = _resolvePath(filename);
    final fullPath = path.join(sharedFolder, filePath.substring(1));

    final dataClient = await _dataListener!.first;
    await _sendResponse(150, 'Opening data connection');

    try {
      final file = File(fullPath);
      final sink = file.openWrite();
      
      await for (var data in dataClient) {
        sink.add(data);
      }
      
      await sink.flush();
      await sink.close();
      await _sendResponse(226, 'Transfer complete');
    } catch (e) {
      await _sendResponse(550, 'Transfer failed');
    } finally {
      _dataListener?.close();
      _dataListener = null;
    }
  }

  Future<void> _handleDele(String filename) async {
    if (!_authenticated) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final filePath = _resolvePath(filename);
    final fullPath = path.join(sharedFolder, filePath.substring(1));

    try {
      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
        await _sendResponse(250, 'File deleted');
      } else {
        await _sendResponse(550, 'File not found');
      }
    } catch (e) {
      await _sendResponse(550, 'Cannot delete file');
    }
  }

  Future<void> _handleMkd(String dirname) async {
    if (!_authenticated) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final dirPath = _resolvePath(dirname);
    final fullPath = path.join(sharedFolder, dirPath.substring(1));

    try {
      await Directory(fullPath).create(recursive: true);
      await _sendResponse(257, '"$dirPath" created');
    } catch (e) {
      await _sendResponse(550, 'Cannot create directory');
    }
  }

  Future<void> _handleRmd(String dirname) async {
    if (!_authenticated) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final dirPath = _resolvePath(dirname);
    final fullPath = path.join(sharedFolder, dirPath.substring(1));

    try {
      final dir = Directory(fullPath);
      if (await dir.exists()) {
        await dir.delete(recursive: true);
        await _sendResponse(250, 'Directory removed');
      } else {
        await _sendResponse(550, 'Directory not found');
      }
    } catch (e) {
      await _sendResponse(550, 'Cannot remove directory');
    }
  }

  Future<void> _handleRnfr(String filename) async {
    if (!_authenticated) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final filePath = _resolvePath(filename);
    final fullPath = path.join(sharedFolder, filePath.substring(1));

    if (await File(fullPath).exists() || await Directory(fullPath).exists()) {
      _renameFrom = fullPath;
      await _sendResponse(350, 'Ready for RNTO');
    } else {
      await _sendResponse(550, 'File/directory not found');
    }
  }

  Future<void> _handleRnto(String filename) async {
    if (!_authenticated || _renameFrom == null) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final filePath = _resolvePath(filename);
    final fullPath = path.join(sharedFolder, filePath.substring(1));

    try {
      if (await File(_renameFrom!).exists()) {
        await File(_renameFrom!).rename(fullPath);
        await _sendResponse(250, 'File renamed');
      } else if (await Directory(_renameFrom!).exists()) {
        await Directory(_renameFrom!).rename(fullPath);
        await _sendResponse(250, 'Directory renamed');
      } else {
        await _sendResponse(550, 'Rename failed');
      }
    } catch (e) {
      await _sendResponse(550, 'Rename failed');
    } finally {
      _renameFrom = null;
    }
  }

  Future<void> _handleSize(String filename) async {
    if (!_authenticated) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final filePath = _resolvePath(filename);
    final fullPath = path.join(sharedFolder, filePath.substring(1));

    try {
      final file = File(fullPath);
      if (await file.exists()) {
        final size = await file.length();
        await _sendResponse(213, size.toString());
      } else {
        await _sendResponse(550, 'File not found');
      }
    } catch (e) {
      await _sendResponse(550, 'Error');
    }
  }

  Future<void> _handleMdtm(String filename) async {
    if (!_authenticated) {
      await _sendResponse(550, 'Permission denied');
      return;
    }

    final filePath = _resolvePath(filename);
    final fullPath = path.join(sharedFolder, filePath.substring(1));

    try {
      final file = File(fullPath);
      if (await file.exists()) {
        final modified = await file.lastModified();
        final timestamp = '${modified.year}${modified.month.toString().padLeft(2, '0')}${modified.day.toString().padLeft(2, '0')}${modified.hour.toString().padLeft(2, '0')}${modified.minute.toString().padLeft(2, '0')}${modified.second.toString().padLeft(2, '0')}';
        await _sendResponse(213, timestamp);
      } else {
        await _sendResponse(550, 'File not found');
      }
    } catch (e) {
      await _sendResponse(550, 'Error');
    }
  }

  String _resolvePath(String relativePath) {
    if (relativePath.startsWith('/')) {
      return path.normalize(relativePath);
    }
    return path.normalize(path.join(_currentDir, relativePath));
  }

  Future<void> _sendResponse(int code, String message) async {
    final response = '$code $message\r\n';
    onLog('<< $code $message');
    _currentSocket?.write(response);
    await _currentSocket?.flush();
  }
}
