import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
  static const String baseUrl = 'http://10.101.105.87:8000';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final prefs = await _prefs;
        await prefs.setString('access_token', data['access_token']);
        await prefs.setString('refresh_token', data['refresh_token']);
        return true;
      }

      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await _prefs;
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<bool> isLoggedIn() async {
    final token = (await _prefs).getString('access_token');
    return token != null;
  }

  Future<String?> getAccessToken() async {
    return (await _prefs).getString('access_token');
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = (await _prefs).getString('access_token');

      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) return json.decode(response.body);
      return null;
    } catch (e) {
      print('Profile error: $e');
      return null;
    }
  }

  Future<bool> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<List<dynamic>> getIngredientsList() async {
    try {
      final token = (await _prefs).getString('access_token');

      final response = await http.get(
        Uri.parse('$baseUrl/ingredients'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) return json.decode(response.body);
      return [];
    } catch (e) {
      print('IngredientList error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getIngredientInfo(String ingredientId) async {
    try {
      final token = (await _prefs).getString('access_token');

      final response = await http.get(
        Uri.parse('$baseUrl/ingredient/$ingredientId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) return json.decode(response.body);
      return null;
    } catch (e) {
      print('IngredientInfo error: $e');
      return null;
    }
  }

  Future<bool> addIngredient(Map<String, dynamic> ingredientData) async {
    try {
      final token = (await _prefs).getString('access_token');

      final response = await http.post(
        Uri.parse('$baseUrl/ingredient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(ingredientData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getMicroNutrients() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/micronutrients'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      print('Error getting micronutrients: $e');
    }
    return [];
  }

  Future<List<dynamic>> getDishesList({bool onlyMine = false}) async {
    final path = onlyMine ? '/dishes/me' : '/dishes';

    try {
      final token = (await _prefs).getString('access_token');

      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) return json.decode(response.body);
      return [];
    } catch (e) {
      print('DishesList error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDishInfo(String dishId) async {
    try {
      final token = (await _prefs).getString('access_token');

      final response = await http.get(
        Uri.parse('$baseUrl/dish/$dishId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) return json.decode(response.body);
      return null;
    } catch (e) {
      print('DishInfo error: $e');
      return null;
    }
  }

  Future<bool> addDish(Map<String, dynamic> dishData, XFile? image) async {
    try {
      final token = (await _prefs).getString('access_token');

      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/dish'))
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['data'] = json.encode(dishData);

      if (image != null) {
        final bytes = await image.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes('image', bytes, filename: image.name),
        );
      }

      final response = await request.send();
      return response.statusCode == 201;
    } catch (e) {
      print('Add dish error: $e');
      return false;
    }
  }

  Future<List<dynamic>> searchUsda(String query) async {
    try {
      final token = (await _prefs).getString('access_token');
      final uri = Uri.parse('$baseUrl/usda-search')
          .replace(queryParameters: {'query': query});

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) return json.decode(response.body);
      return [];
    } catch (e) {
      print('USDA Search error: $e');
      return [];
    }
  }

  Future<bool> syncUsdaIngredient(Map<String, dynamic> usdaData) async {
    try {
      final token = (await _prefs).getString('access_token');

      final response = await http.post(
        Uri.parse('$baseUrl/sync-usda'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(usdaData),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('USDA Sync error: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> getConsumptionReport({int days = 1}) async {
    try {
      final token = (await _prefs).getString('access_token');

      final response = await http.get(
        Uri.parse('$baseUrl/consumption/report?days=$days'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) return json.decode(response.body);
      return null;
    } catch (e) {
      print('Report Error: $e');
      return null;
    }
  }

  Future<bool> logConsumption(Map<String, dynamic> payload) async {
    try {
      final token = (await _prefs).getString('access_token');

      final response = await http.post(
        Uri.parse('$baseUrl/consumption/log'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('logConsumption error: $e');
      return false;
    }
  }
}
