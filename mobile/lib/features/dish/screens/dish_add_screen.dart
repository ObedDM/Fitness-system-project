import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';
import '../widgets/dish_ingredient_button.dart';
import '../widgets/dish_ingredient_modal.dart';
import 'package:image_picker/image_picker.dart';


class DishAddScreen extends StatefulWidget {
  const DishAddScreen({super.key});

  @override
  State<DishAddScreen> createState() => _DishAddScreenState();
}

class _DishAddScreenState extends State<DishAddScreen> {
  XFile? _image;
  final _scrollController = ScrollController();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _servingsController = TextEditingController();
  
  String _selectedCategory = 'breakfast';
  final List<Map<String, dynamic>> _ingredients = [];
  
  void _showIngredientsModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DishIngredientModal(
        ingredients: _ingredients,
        onDelete: (index) {
          setState(() {
            _ingredients.removeAt(index);
          });
        },
      ),
    );

    setState(() {});
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _servingsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Dish')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(size.width * 0.05),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: "Dish name",
                      prefixIcon: const Icon(Icons.restaurant),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black, width: 1.2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Description",
                      prefixIcon: const Icon(Icons.description),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black, width: 1.2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Servings",
                      prefixIcon: const Icon(Icons.people),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.black, width: 1.2),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  DropdownMenu<String>(
                    width: size.width * 0.9,
                    initialSelection: _selectedCategory,
                    label: const Text('Category'),
                    dropdownMenuEntries: const [
                      DropdownMenuEntry(value: 'breakfast', label: 'Breakfast'),
                      DropdownMenuEntry(value: 'lunch', label: 'Lunch'),
                      DropdownMenuEntry(value: 'dinner', label: 'Dinner'),
                      DropdownMenuEntry(value: 'snack', label: 'Snack'),
                      DropdownMenuEntry(value: 'dessert', label: 'Dessert'),
                    ],
                    onSelected: (value) {
                      setState(() {
                        _selectedCategory = value ?? 'breakfast';
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  DishIngredientButton(
                    ingredients: _ingredients,
                    onTap: _showIngredientsModal,
                  ),

                  const SizedBox(height: 16),

                  ElevatedButton(
                    onPressed: () async {
                      final file = await ImagePicker().pickImage(source: ImageSource.gallery);
                      if (file != null) setState(() => _image = file);
                    },
                    child: Text(_image == null ? 'Add image' : 'Image selected'),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        final ingredientsPayload = _ingredients.map((ing) {
                          return {
                            'ingredient_id': ing['ingredient_id'],
                            'amount': ing['amount'],
                            'unit': ing['unit'],
                          };
                        }).toList();

                        final dishData = {
                          'name': _nameController.text,
                          'description': _descriptionController.text,
                          'servings': double.tryParse(_servingsController.text) ?? 1.0,
                          'category': _selectedCategory,
                          'ingredients': ingredientsPayload,
                        };

                        final success = await AuthService().addDish(dishData, _image);
                        
                        if (success) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Dish created!')),
                            );
                            Navigator.pop(context);
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to create dish')),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 192, 255, 179),
                      ),
                      child: const Text(
                        'Create Dish',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
