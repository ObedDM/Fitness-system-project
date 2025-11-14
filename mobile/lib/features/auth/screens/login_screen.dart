  import 'package:flutter/material.dart';

  class LoginScreen extends StatefulWidget {
    const LoginScreen({super.key});

    @override
    State<LoginScreen> createState() => _LoginScreenState();
  }

  class _LoginScreenState extends State<LoginScreen> {
    @override
    Widget build(BuildContext context) {
      final size = MediaQuery.of(context).size;

      return Scaffold(
        body: 
          SafeArea(
            child: 
              Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child:
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Welcome text
                      Text(
                        "Please Log-in",
                        style: TextStyle(fontSize: 24),
                      ),

                      // Blank space
                      const SizedBox(height: 32),

                      // Email text field
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email",
                          prefixIcon: Icon(Icons.mail),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      // Blank space
                      const SizedBox(height: 16),

                      // Password text field
                      TextField(
                        keyboardType: TextInputType.emailAddress,
                        obscureText: true,
                        decoration: InputDecoration(
                          hintText: "Password",
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
              ),
          )
      );
    }
  }