import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mobile/features/ingredients/widgets/micronutrient_button.dart';
import 'package:mobile/features/ingredients/widgets/micronutrient_modal.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_keyboard.dart';

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

  void _showMicronutrientsModal() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => MicronutrientModal(
        micronutrients: _micronutrients,
        onDelete: (index) => setState(() => _micronutrients.removeAt(index)),
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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.black, width: 1.2),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ingredient', style: TextStyle(fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: true,
      ),
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
                        const SizedBox(height: 8),

                        _field(_nameController, InputDecoration(
                          hintText: "name",
                          prefixIcon: const Icon(Icons.fastfood_rounded),
                          enabledBorder: border,
                        )),
                        const SizedBox(height: 16),

                        _field(_caloriesController, InputDecoration(
                          hintText: "calories",
                          prefixIcon: const Icon(Icons.light),
                          enabledBorder: border,
                        )),
                        const SizedBox(height: 16),

                        _field(_proteinController, InputDecoration(
                          hintText: "protein",
                          prefixIcon: const Icon(Icons.place),
                          enabledBorder: border,
                        )),
                        const SizedBox(height: 16),

                        _field(_fatController, InputDecoration(
                          hintText: "fat",
                          prefixIcon: const Icon(Icons.place),
                          enabledBorder: border,
                        )),
                        const SizedBox(height: 16),

                        _field(_carbohydratesController, InputDecoration(
                          hintText: "carbohydrates",
                          prefixIcon: const Icon(Icons.place),
                          enabledBorder: border,
                        )),
                        const SizedBox(height: 16),

                        MicronutrientButton(
                          micronutrients: _micronutrients,
                          onTap: _showMicronutrientsModal,
                        ),
                        const SizedBox(height: 16),

                        _field(_waterController, InputDecoration(
                          hintText: "water",
                          prefixIcon: const Icon(Icons.water_drop_outlined),
                          enabledBorder: border,
                        )),
                        const SizedBox(height: 16),

                        _field(_glycemicIndexController, InputDecoration(
                          hintText: "glycemic index",
                          prefixIcon: const Icon(Icons.place),
                          enabledBorder: border,
                        )),
                        const SizedBox(height: 24),

                        MaterialButton(
                          onPressed: () async {
                            final micronutrientsPayload = <String, num>{};
                            for (final m in _micronutrients) {
                              micronutrientsPayload[m['name'] as String] = m['quantity'] as num;
                            }

                            final ingredientData = <String, dynamic>{
                              'name': _nameController.text,
                              'calories': _caloriesController.text,
                              'protein': _proteinController.text,
                              'fat': _fatController.text,
                              'carbohydrates': _carbohydratesController.text,
                              'water': _waterController.text,
                              'glycemic_index': _glycemicIndexController.text,
                              'micronutrients': micronutrientsPayload,
                            };

                            final success = await AuthService().addIngredient(ingredientData);
                            if (!mounted) return;
                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Ingredient created!')),
                              );
                              Navigator.pushReplacementNamed(context, '/login');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to create ingredient')),
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
                            'Create Ingredient',
                            style: TextStyle(color: Colors.black, fontSize: 16),
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
