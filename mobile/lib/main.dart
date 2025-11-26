import 'package:flutter/material.dart';
import 'package:mobile/features/auth/screens/login_Screen.dart';
import 'package:mobile/features/auth/screens/register_screen.dart';
import 'package:mobile/features/home/screens/home_screen.dart';
import 'package:mobile/features/ingredients/screens/ingredient_add_screen.dart';
import 'package:mobile/features/ingredients/screens/ingredient_info_screen.dart';
import 'package:mobile/features/ingredients/screens/ingredients_list_screen.dart';
import 'package:mobile/features/profile/screens/profile_screen.dart';
import 'package:mobile/services/auth_service.dart';

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
      home: AuthCheck(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFFF2FFF2)
        )
      ),
      initialRoute: '/auth/login',
      routes: {
        '/auth/login': (context) => LoginScreen(),
        '/auth/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/ingredients/list': (context) => IngredientsListScreen(),
        '/ingredient/info': (context) => IngredientInfoScreen(),
        '/ingredient/add': (context) => IngredientAddScreen(),
      },
    );
  }
}

class AuthCheck extends StatelessWidget {
  final _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return HomeScreen();
        } else {
          return LoginScreen();
        }
      },
    );
  }
}