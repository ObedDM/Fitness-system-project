import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../../services/auth_service.dart';
import '../../../widgets/custom_keyboard.dart';

class UsdaSearchScreen extends StatefulWidget {
  const UsdaSearchScreen({super.key});

  @override
  State<UsdaSearchScreen> createState() => _UsdaSearchScreenState();
}

class _UsdaSearchScreenState extends State<UsdaSearchScreen> {
  final _authService = AuthService();
  final _searchController = TextEditingController();

  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  bool _isSyncing = false;
  bool _showKeyboard = false;
  bool _capsLock = false;

  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _showKeyboard = false;
    });

    final results = await _authService.searchUsda(query);

    setState(() {
      _searchResults = results;
      _isLoading = false;
    });
  }

  Future<void> _importIngredient(Map<String, dynamic> usdaItem) async {
    setState(() => _isSyncing = true);
    final success = await _authService.syncUsdaIngredient(usdaItem);
    setState(() => _isSyncing = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${usdaItem['description']} imported successfully!')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to import ingredient.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search USDA Database")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search bar
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _showKeyboard = true),
                    behavior: HitTestBehavior.translucent,
                    child: IgnorePointer(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "e.g. Raw Banana",
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _performSearch,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Icon(Icons.arrow_forward),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Results
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _searchResults.isEmpty
                      ? const Center(child: Text("No results found."))
                      : ScrollConfiguration(
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
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final item = _searchResults[index];
                              final name = item['description'] ?? 'Unknown';
                              final brand = item['brandOwner'] ?? 'Generic';
                              final id = item['fdcId'];

                              return Card(
                                margin: const EdgeInsets.only(bottom: 10),
                                child: ListTile(
                                  leading: const Icon(Icons.cloud_download, color: Colors.blue),
                                  title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  subtitle: Text("$brand (ID: $id)"),
                                  trailing: _isSyncing
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const Icon(Icons.add_circle_outline),
                                  onTap: _isSyncing ? null : () => _importIngredient(item),
                                ),
                              );
                            },
                          ),
                        ),
            ),

            // Teclado virtual
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
                controller: _searchController,
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
