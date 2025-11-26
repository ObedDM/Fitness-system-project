import 'package:flutter/material.dart';
import 'package:mobile/features/ingredients/widgets/ingredient_card.dart';
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
    final data = await _authService.getIngredientsList();
    setState(() {
      _ingredientsListData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingredients')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _ingredientsListData == null
              ? Center(child: Text('Error loading IngredientsListScreen'))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _ingredientsListData!.length,
                          itemBuilder: (context, index) {
                            final ingredient = _ingredientsListData![index];
                            
                            return IngredientCard(
                              ingredient: ingredient,
                              onTap: () => Navigator.pushNamed(context, '/ingredient/info', arguments: ingredient['ingredient_id'])
                            );
                          },
                        ),
                      ),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(255, 165, 255, 165),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/ingredient/add'),
                          child:
                            Text('Add ingredient')
                        ),
                      )
                    ],
                  )
                ),
    );
  }
}