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
        child: 
        Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Go back to login screen button
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MaterialButton(
                      onPressed: () => {
                        Navigator.pushNamed(context, '/login')
                      },
                      color: const Color.fromARGB(255, 76, 194, 102),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.black,
                          width: 0.3
                        )
                      ),
                      child: const Text(
                        'Go back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    )
                  ]
                ),

                // Blanck space
                const SizedBox(height: 16),

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
        )
      ),
    );
  }
}