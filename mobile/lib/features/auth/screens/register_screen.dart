import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_keyboard.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String _selectedRole = 'usuario';

  bool _showKeyboard = false;
  bool _capsLock = false;
  TextEditingController? _activeController;

  @override
  void dispose() {
    _usernameController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Widget _field(TextEditingController controller, InputDecoration decoration,
      {bool obscure = false}) {
    return GestureDetector(
      onTap: () => setState(() {
        _activeController = controller;
        _showKeyboard = true;
      }),
      behavior: HitTestBehavior.translucent, // no bloquea scroll al padre
      child: IgnorePointer( // solo ignora eventos en el TextField, no los absorbe
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: decoration,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(12));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text("Create Account"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Contenido principal scrolleable ──
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.stylus,
                    PointerDeviceKind.trackpad,
                  },
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(size.width * 0.05),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      _field(_usernameController, InputDecoration(
                        hintText: "Username",
                        prefixIcon: const Icon(Icons.person),
                        border: border,
                      )),
                      const SizedBox(height: 16),

                      _field(_nameController, InputDecoration(
                        hintText: "Name",
                        prefixIcon: const Icon(Icons.badge),
                        border: border,
                      )),
                      const SizedBox(height: 16),

                      _field(_surnameController, InputDecoration(
                        hintText: "Surname",
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: border,
                      )),
                      const SizedBox(height: 16),

                      _field(_emailController, InputDecoration(
                        hintText: "Email",
                        prefixIcon: const Icon(Icons.email),
                        border: border,
                      )),
                      const SizedBox(height: 16),

                      _field(_passwordController, InputDecoration(
                        hintText: "Password",
                        prefixIcon: const Icon(Icons.lock),
                        border: border,
                      ), obscure: true),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          hintText: "Role",
                          prefixIcon: const Icon(Icons.work),
                          border: border,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                          DropdownMenuItem(value: 'nutriologo', child: Text('Nutriólogo')),
                        ],
                        onChanged: (value) => setState(() => _selectedRole = value!),
                      ),
                      const SizedBox(height: 16),

                      _field(_ageController, InputDecoration(
                        hintText: "Age (optional)",
                        prefixIcon: const Icon(Icons.calendar_today),
                        border: border,
                      )),
                      const SizedBox(height: 16),

                      _field(_weightController, InputDecoration(
                        hintText: "Weight in kg (optional)",
                        prefixIcon: const Icon(Icons.monitor_weight),
                        border: border,
                      )),
                      const SizedBox(height: 16),

                      _field(_heightController, InputDecoration(
                        hintText: "Height in meters (optional)",
                        prefixIcon: const Icon(Icons.height),
                        border: border,
                      )),
                      const SizedBox(height: 24),

                      MaterialButton(
                        onPressed: () async {
                          final userData = <String, dynamic>{
                            'username': _usernameController.text,
                            'name': _nameController.text,
                            'surname': _surnameController.text,
                            'email': _emailController.text,
                            'password': _passwordController.text,
                            'role': _selectedRole,
                          };
                          if (_ageController.text.isNotEmpty)
                            userData['age'] = int.tryParse(_ageController.text);
                          if (_weightController.text.isNotEmpty)
                            userData['weight'] = double.tryParse(_weightController.text);
                          if (_heightController.text.isNotEmpty)
                            userData['height'] = double.tryParse(_heightController.text);

                          final success = await AuthService().register(userData);
                          if (!mounted) return;
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Account created! Please login')),
                            );
                            Navigator.pushReplacementNamed(context, '/login');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Registration failed')),
                            );
                          }
                        },
                        color: const Color.fromARGB(255, 192, 255, 179),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.black, width: 0.3),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),

            // ── Teclado virtual ──
            if (_showKeyboard) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_hide),
                    onPressed: () => setState(() => _showKeyboard = false),
                  ),
                ],
              ),
              CustomKeyboard(
                controller: _activeController!,
                capsLock: _capsLock,
                onCapsLock: () => setState(() => _capsLock = !_capsLock),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
