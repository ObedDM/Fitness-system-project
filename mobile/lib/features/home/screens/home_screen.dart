import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Placeholder Text
            Text(
              'Welcome to HomeScreen',
              style: TextStyle(
                color: Colors.black,
                fontSize: 30
              ),
            )
          ],
        ),
      ),
    );
  }
}