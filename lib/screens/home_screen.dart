import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:network_info_plus/network_info_plus.dart';
import '../services/ftps_server.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  FtpsServer? _server;
  final List<String> _logs = [];
  bool _isRunning = false;
  String? _sharedFolder;
  String _ipAddress = 'Detecting...';
  
  final TextEditingController _portController = TextEditingController(text: '2121');
  final TextEditingController _usernameController = TextEditingController(text: 'admin');
  final TextEditingController _passwordController = TextEditingController(text: 'password');

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _getIpAddress();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _portController.text = prefs.getString('port') ?? '2121';
      _usernameController.text = prefs.getString('username') ?? 'admin';
      _passwordController.text = prefs.getString('password') ?? 'password';
      _sharedFolder = prefs.getString('sharedFolder');
    });

    if (_sharedFolder == null) {
      final dir = await getApplicationDocumentsDirectory();
      final defaultFolder = '${dir.path}/ftps_shared';
      await Directory(defaultFolder).create(recursive: true);
      setState(() {
        _sharedFolder = defaultFolder;
      });
      await prefs.setString('sharedFolder', defaultFolder);
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('port', _portController.text);
    await prefs.setString('username', _usernameController.text);
    await prefs.setString('password', _passwordController.text);
    if (_sharedFolder != null) {
      await prefs.setString('sharedFolder', _sharedFolder!);
    }
  }

  Future<void> _getIpAddress() async {
    try {
      final info = NetworkInfo();
      final wifiIP = await info.getWifiIP();
      setState(() {
        _ipAddress = wifiIP ?? 'Unable to detect';
      });
    } catch (e) {
      setState(() {
        _ipAddress = 'Error detecting IP';
      });
    }
  }

  Future<void> _selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    
    if (selectedDirectory != null) {
      setState(() {
        _sharedFolder = selectedDirectory;
      });
      await _saveSettings();
    }
  }

  Future<void> _startServer() async {
    if (_sharedFolder == null) {
      _showError('Please select a shared folder first');
      return;
    }

    await _saveSettings();

    try {
      final port = int.parse(_portController.text);
      
      _server = FtpsServer(
        port: port,
        username: _usernameController.text,
        password: _passwordController.text,
        sharedFolder: _sharedFolder!,
      );

      _server!.logStream.listen((log) {
        setState(() {
          _logs.add(log);
          if (_logs.length > 100) _logs.removeAt(0);
        });
      });

      await _server!.start();

      setState(() {
        _isRunning = true;
      });
    } catch (e) {
      _showError('Failed to start server: $e');
    }
  }

  Future<void> _stopServer() async {
    if (_server != null) {
      await _server!.stop();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FTPS File Server'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isRunning ? Icons.circle : Icons.circle_outlined,
                          color: _isRunning ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isRunning ? 'Server Running' : 'Server Stopped',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('IP Address: $_ipAddress'),
                    Text('Port: ${_portController.text}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Configuration Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Configuration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _portController,
                      decoration: const InputDecoration(
                        labelText: 'Port',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      enabled: !_isRunning,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isRunning,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      enabled: !_isRunning,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _sharedFolder ?? 'No folder selected',
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _isRunning ? null : _selectFolder,
                          icon: const Icon(Icons.folder_open),
                          label: const Text('Select Folder'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Control Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isRunning ? null : _startServer,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start Server'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !_isRunning ? null : _stopServer,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop Server'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Logs Card
            Expanded(
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Server Logs',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _logs.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: _logs.isEmpty
                          ? const Center(
                              child: Text('No logs yet'),
                            )
                          : ListView.builder(
                              itemCount: _logs.length,
                              reverse: true,
                              itemBuilder: (context, index) {
                                final reversedIndex = _logs.length - 1 - index;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 4.0,
                                  ),
                                  child: Text(
                                    _logs[reversedIndex],
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _server?.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
