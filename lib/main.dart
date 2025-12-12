import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FtpsServerApp());
}

class FtpsServerApp extends StatelessWidget {
  const FtpsServerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FTPS File Server',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
