import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mobile/services/auth_service.dart';
import '../widgets/dish_ingredient_button.dart';
import '../widgets/dish_ingredient_modal.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../widgets/custom_keyboard.dart';

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

  bool _showKeyboard = false;
  bool _capsLock = false;
  TextEditingController? _activeController;

  Widget _field(TextEditingController controller, InputDecoration decoration,
      {bool obscure = false}) {
    return GestureDetector(
      onTap: () => setState(() {
        _activeController = controller;
        _showKeyboard = true;
      }),
      behavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        child: TextField(
          controller: controller,
          obscureText: obscure,
          decoration: decoration,
        ),
      ),
    );
  }

  void _showIngredientsModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DishIngredientModal(
        ingredients: _ingredients,
        onDelete: (index) => setState(() => _ingredients.removeAt(index)),
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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 1.2),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Create Dish')),
      body: SafeArea(
        child: Column(
          children: [
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
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.all(size.width * 0.05),
                    child: Column(
                      children: [
                        _field(_nameController, InputDecoration(
                          hintText: "Dish name",
                          prefixIcon: const Icon(Icons.restaurant),
                          enabledBorder: border,
                        )),
                        const SizedBox(height: 16),

                        _field(_descriptionController, InputDecoration(
                          hintText: "Description",
                          prefixIcon: const Icon(Icons.description),
                          enabledBorder: border,
                        )),
                        const SizedBox(height: 16),

                        _field(_servingsController, InputDecoration(
                          hintText: "Servings",
                          prefixIcon: const Icon(Icons.people),
                          enabledBorder: border,
                        )),
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
                          onSelected: (value) =>
                              setState(() => _selectedCategory = value ?? 'breakfast'),
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
                              final ingredientsPayload = _ingredients.map((ing) => {
                                'ingredient_id': ing['ingredient_id'],
                                'amount': ing['amount'],
                                'unit': ing['unit'],
                              }).toList();

                              final dishData = {
                                'name': _nameController.text,
                                'description': _descriptionController.text,
                                'servings': double.tryParse(_servingsController.text) ?? 1.0,
                                'category': _selectedCategory,
                                'ingredients': ingredientsPayload,
                              };

                              final success = await AuthService().addDish(dishData, _image);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(success ? 'Dish created!' : 'Failed to create dish')),
                                );
                                if (success) Navigator.pop(context);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 192, 255, 179),
                            ),
                            child: const Text(
                              'Create Dish',
                              style: TextStyle(color: Colors.black, fontSize: 16),
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
