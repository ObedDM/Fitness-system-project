import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:mobile/features/dish/widgets/dish_card.dart';
import '../../../services/auth_service.dart';

class DishesListScreen extends StatefulWidget {
  const DishesListScreen({super.key});

  @override
  State<DishesListScreen> createState() => _DishesListScreenState();
}

class _DishesListScreenState extends State<DishesListScreen> {
  final _authService = AuthService();
  List<dynamic>? _dishesListData;
  bool _isLoading = true;
  bool _myDishes = false;

  @override
  void initState() {
    super.initState();
    _loadDishesListScreen();
  }

  Future<void> _loadDishesListScreen() async {
    setState(() => _isLoading = true);
    final data = await _authService.getDishesList(onlyMine: _myDishes);
    setState(() {
      _dishesListData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dishes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDishesListScreen,
          ),
          TextButton(
            onPressed: () {
              setState(() => _myDishes = !_myDishes);
              _loadDishesListScreen();
            },
            child: Text(
              _myDishes ? 'All dishes' : 'My dishes',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _dishesListData == null
              ? const Center(child: Text('Error loading DishesListScreen'))
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
                            itemCount: _dishesListData!.length,
                            itemBuilder: (context, index) {
                              final dish = _dishesListData![index];
                              return DishCard(
                                dish: dish,
                                onTap: () => Navigator.pushNamed(
                                  context,
                                  '/dish/info',
                                  arguments: dish['dish_id'],
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
                            backgroundColor: const Color.fromARGB(255, 165, 255, 165),
                          ),
                          onPressed: () => Navigator.pushNamed(context, '/dish/add'),
                          child: const Text('Add dish'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
