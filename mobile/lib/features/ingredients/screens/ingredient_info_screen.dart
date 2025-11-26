import 'package:flutter/material.dart';
import 'package:mobile/services/auth_service.dart';

class IngredientInfoScreen extends StatefulWidget {
  const IngredientInfoScreen({super.key});

  @override
  State<IngredientInfoScreen> createState() => _IngredientInfoScreenState();
}

class _IngredientInfoScreenState extends State<IngredientInfoScreen> {
  final _authService = AuthService();
  Map<String, dynamic>? _ingredientInfoData;
  bool _isLoading = true;

    @override
    void didChangeDependencies() {
      super.didChangeDependencies();
      _loadIngredientInfo();
    }

    Future<void> _loadIngredientInfo() async {
    final ingredientId = ModalRoute.of(context)?.settings.arguments as String?;
    if (ingredientId != null) {
      final data = await _authService.getIngredientInfo(ingredientId);
      setState(() {
        _ingredientInfoData = data;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ingredient Info')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _ingredientInfoData == null
              ? Center(child: Text('Error loading ingredient'))
              : Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      Text('Ingredient Data:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      SizedBox(height: 20),
                      ..._ingredientInfoData!.entries.map((entry) => 
                        Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text('${entry.key}: ${entry.value}', style: TextStyle(fontSize: 16)),
                        )
                      ).toList(),
                    ],
                  ),
                ),
    );
  }
}