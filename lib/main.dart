import 'package:chat_app/screen/auth_screen.dart';
import 'package:flutter/material.dart';

import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: lightTheme,
      darkTheme: darkTheme,
      home: const AuthScreen(),
    );
  }
}
