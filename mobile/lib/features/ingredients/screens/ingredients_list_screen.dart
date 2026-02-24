import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mobile/features/ingredients/widgets/ingredient_card.dart';
import 'package:mobile/features/ingredients/screens/usda_search_screen.dart';
import '../../../services/auth_service.dart';

class IngredientsListScreen extends StatefulWidget {
  const IngredientsListScreen({super.key});

  @override
  State<IngredientsListScreen> createState() => _IngredientsListScreenState();
}

class _IngredientsListScreenState extends State<IngredientsListScreen> {
  final _authService = AuthService();
  List<dynamic>? _ingredientsListData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIngredientsListScreen();
  }

  Future<void> _loadIngredientsListScreen() async {
    setState(() => _isLoading = true);
    final data = await _authService.getIngredientsList();
    setState(() {
      _ingredientsListData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredients'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadIngredientsListScreen,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _ingredientsListData == null
              ? const Center(child: Text('Error loading IngredientsListScreen'))
              : Padding(
                  padding: const EdgeInsets.all(16),
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
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _ingredientsListData!.length,
                            itemBuilder: (context, index) {
                              final ingredient = _ingredientsListData![index];
                              return IngredientCard(
                                ingredient: ingredient,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/ingredient/info',
                                  arguments: ingredient['ingredient_id'],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UsdaSearchScreen()),
                            );
                            if (result == true) _loadIngredientsListScreen();
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search),
                              SizedBox(width: 10),
                              Text('Import from USDA (Auto)'),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 165, 255, 165),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/ingredient/add'),
                          child: const Text('Add ingredient'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
