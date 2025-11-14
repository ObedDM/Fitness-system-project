import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/login_Screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'Fitness meal tracker',
      home: const LoginScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFF2FFF2)
        ) 
      ),
    );
  }
}
