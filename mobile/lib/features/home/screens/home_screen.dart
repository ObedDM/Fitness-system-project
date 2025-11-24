import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (!isLoggedIn && mounted) {
      Navigator.pushReplacementNamed(context, '/auth/login');
    }
  }

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

                // Go to profile button
                MaterialButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  child: Text('View Profile'),
                ),

                // Go back to login screen button
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    MaterialButton(
                      onPressed: () async {
                        await _authService.logout();
                        Navigator.pushNamed(context, '/auth/login');
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
                        'Log out',
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