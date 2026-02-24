import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_keyboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _showKeyboard = false;
  bool _capsLock = false;
  TextEditingController? _activeController;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.05),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Please Log-in", style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 32),

                    // Username
                    GestureDetector(
                      onTap: () {
                        print('TAP USERNAME');
                        setState(() {
                          _activeController = _usernameController;
                          _showKeyboard = true;
                        });
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: "Username",
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password
                    GestureDetector(
                      onTap: () {
                        print('TAP PASSWORD');
                        setState(() {
                          _activeController = _passwordController;
                          _showKeyboard = true;
                        });
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Password",
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Forgot your password?',
                          style: TextStyle(
                            color: Colors.black,
                            decoration: TextDecoration.underline,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        MaterialButton(
                          onPressed: () async {
                            final success = await _authService.login(
                              _usernameController.text,
                              _passwordController.text,
                            );
                            if (success) {
                              Navigator.pushNamed(context, '/home');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Login Failed')),
                              );
                            }
                          },
                          color: const Color.fromARGB(255, 192, 255, 179),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.black, width: 0.3),
                          ),
                          child: const Text(
                            'Login',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    MaterialButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/auth/register'),
                      child: Text('Create account'),
                    ),
                  ],
                ),
              ),
            ),

            // Teclado virtual
            if (_showKeyboard) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(Icons.keyboard_hide),
                    onPressed: () => setState(() => _showKeyboard = false),
                  ),
                ],
              ),
              CustomKeyboard(
                controller: _activeController!,
                capsLock: _capsLock,
                onCapsLock: () => setState(() => _capsLock = !_capsLock),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
