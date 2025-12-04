import 'package:flutter/material.dart';
import 'package:mobile/features/home/widgets/home_dishes_card.dart';
import 'package:mobile/features/home/widgets/home_ingredients_card.dart';
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
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          // Go to profile button
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/profile'),
            icon: const Icon(Icons.person),
            ),
        ],
      ),

      body: Padding(
        padding: EdgeInsets.all(size.width * 0.05),
        child: 
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              const Text(
              'What do you want to explore?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 24),

            const SizedBox(height: 24),

            const HomeIngredientsCard(),

            const SizedBox(height: 16),

            const HomeDishesCard(),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  await _authService.logout();
                  if (mounted) {
                    Navigator.pushReplacementNamed(context, '/auth/login');
                  }
                },
                child: const Text(
                  'Log out',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ],
          ),
      )
    );
  }
}











