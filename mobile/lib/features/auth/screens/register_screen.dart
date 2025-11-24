import 'package:flutter/material.dart';
import '../../../services/auth_service.dart';

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
                      "create-account",
                      style: TextStyle(fontSize: 24),
                    ),

                    // Blank space
                    const SizedBox(height: 32),

                    // Username (required)
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: "Username",
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Blank space
                    const SizedBox(height: 16),

                    // Name (required)
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Name",
                        prefixIcon: Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Surname (required)
                    TextField(
                      controller: _surnameController,
                      decoration: InputDecoration(
                        hintText: "Surname",
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email (required)
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Password text field
                    TextField(
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

                    // Blank space
                    const SizedBox(height: 16),

                    // Role Dropdown (required)
                    DropdownButtonFormField<String>(
                      initialValue: _selectedRole,
                      decoration: InputDecoration(
                        hintText: "Role",
                        prefixIcon: Icon(Icons.work),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'usuario', child: Text('Usuario')),
                        DropdownMenuItem(value: 'nutriologo', child: Text('Nutriólogo')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),

                    // Blank space
                    const SizedBox(height: 16),

                    // Age (optional)
                    TextField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Age (optional)",
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Blank space
                    const SizedBox(height: 16),

                    // Weight (optional)
                    TextField(
                      controller: _weightController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: "Weight in kg (optional)",
                        prefixIcon: Icon(Icons.monitor_weight),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Blank space
                    const SizedBox(height: 16),

                    // Height (optional)
                    TextField(
                      controller: _heightController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: "Height in meters (optional)",
                        prefixIcon: Icon(Icons.height),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    // Blank space
                    const SizedBox(height: 24),

                    // Register Button
                    MaterialButton(
                      onPressed: () async {
                        final userData = <String, dynamic> {
                          'username': _usernameController.text,
                          'name': _nameController.text,
                          'surname': _surnameController.text,
                          'email': _emailController.text,
                          'password': _passwordController.text,
                          'role': _selectedRole,
                        };

                        if (_ageController.text.isNotEmpty) {
                          userData['age'] = int.tryParse(_ageController.text);
                        }
                        if (_weightController.text.isNotEmpty) {
                          userData['weight'] = double.tryParse(_weightController.text);
                        }
                        if (_heightController.text.isNotEmpty) {
                          userData['height'] = double.tryParse(_heightController.text);
                        }

                        final success = await AuthService().register(userData);

                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Account created! Please login')),
                          );
                          Navigator.pushReplacementNamed(context, '/login');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Registration failed')),
                          );
                        }
                      },
                      color: const Color.fromARGB(255, 192, 255, 179),
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
                        'Create Account',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),

                    // Blank space
                    const SizedBox(height: 32),
                  ],
                ),
            ),
        )
    );
  }
}