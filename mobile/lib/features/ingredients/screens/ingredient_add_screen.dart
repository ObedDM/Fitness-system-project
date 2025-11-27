import 'package:flutter/material.dart';
import 'package:mobile/features/ingredients/widgets/micronutrient_button.dart';
import 'package:mobile/features/ingredients/widgets/micronutrient_modal.dart';
import '../../../services/auth_service.dart';

class IngredientAddScreen extends StatefulWidget {
  const IngredientAddScreen({super.key});

  @override
  State<IngredientAddScreen> createState() => _IngredientAddScreenState();
}

class _IngredientAddScreenState extends State<IngredientAddScreen> {
  final _scrollController = ScrollController();

  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _fatController = TextEditingController();
  final _carbohydratesController = TextEditingController();
  final _waterController = TextEditingController();
  final _glycemicIndexController = TextEditingController();

  final List<Map<String, dynamic>> _micronutrients = [];
  
    void _showMicronutrientsModal() async {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => MicronutrientModal(
          micronutrients: _micronutrients,
          onDelete: (index) {
            setState(() {
              _micronutrients.removeAt(index);
            });
          }
        ),
      );

      setState(() {});
    }

    @override
    void dispose() {
      _scrollController.dispose();
      _nameController.dispose();
      _caloriesController.dispose();
      _proteinController.dispose();
      _fatController.dispose();
      _carbohydratesController.dispose();
      _waterController.dispose();
      _glycemicIndexController.dispose();
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
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [

                      Text(
                        "create ingredient",
                        style: TextStyle(fontSize: 24),
                      ),

                      // Blank space
                      const SizedBox(height: 32),

                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          hintText: "name",
                          prefixIcon: Icon(Icons.fastfood_rounded),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.2)
                          ),
                        ),
                      ),

                      // Blank space
                      const SizedBox(height: 16),

                      TextField(
                        controller: _caloriesController,
                        decoration: InputDecoration(
                          hintText: "calories",
                          prefixIcon: Icon(Icons.light),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.2)
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _proteinController,
                        decoration: InputDecoration(
                          hintText: "protein",
                          prefixIcon: Icon(Icons.place),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.2)
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _fatController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "fat",
                          prefixIcon: Icon(Icons.place),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.2)
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      TextField(
                        controller: _carbohydratesController,
                        decoration: InputDecoration(
                          hintText: "carbohydrates",
                          prefixIcon: Icon(Icons.place),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.2)
                          ),
                        ),
                      ),

                      // Blank space
                      const SizedBox(height: 16),

                      MicronutrientButton(
                        micronutrients: _micronutrients,
                        onTap: _showMicronutrientsModal,
                      ),

                      // Blank space
                      const SizedBox(height: 16),

                      TextField(
                        controller: _waterController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "water",
                          prefixIcon: Icon(Icons.water_drop_outlined),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.2)
                          ),
                        ),
                      ),

                      // Blank space
                      const SizedBox(height: 16),

                      TextField(
                        controller: _glycemicIndexController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "glycemic index",
                          prefixIcon: Icon(Icons.place),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 1.2)
                          ),
                        ),
                      ),

                      // Blank space
                      const SizedBox(height: 24),

                      // IngredientAddScreen Button
                      MaterialButton(
                        onPressed: () async {
                          final micronutrientsPayload = <String, num>{};
                          for (final m in _micronutrients) {
                            final name = m['name'] as String;
                            final quantity = m['quantity'] as num;

                            micronutrientsPayload[name] = quantity;
                          }


                          final ingredientData = <String, dynamic> {
                            'name': _nameController.text,
                            'calories': _caloriesController.text,
                            'protein': _proteinController.text,
                            'fat': _fatController.text,
                            'carbohydrates': _carbohydratesController.text,
                            'water': _waterController.text,
                            'glycemic_index': _glycemicIndexController.text,
                            'micronutrients': micronutrientsPayload,
                          };

                          print(ingredientData);

                          final success = await AuthService().addIngredient(ingredientData);

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
                          'Create Ingredient',
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
                )
              )
            ),
        )
    );
  }
}