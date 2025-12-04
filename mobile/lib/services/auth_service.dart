import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000';
  final storage = const FlutterSecureStorage();

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await storage.write(key: 'access_token', value: data['access_token']);
        await storage.write(key: 'refresh_token', value: data['refresh_token']);
        return true;
      }

      return false;
      
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await storage.delete(key: 'access_token');
    await storage.delete(key: 'refresh_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: 'access_token');
    return token != null;
  }

  Future<String?> getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
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
      final token = await storage.read(key: 'access_token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/ingredients'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('IngredientList error: $e');
      return [];
    }
  }

    Future<Map<String, dynamic>?> getIngredientInfo(String ingredientId) async {
    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/ingredient/$ingredientId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('IngredientInfo error: $e');
      return null;
    }
  }

  Future<bool> addIngredient(Map<String, dynamic> ingredientData) async {
    try {
      final token = await storage.read(key: 'access_token');

      final response = await http.post(
        Uri.parse('$baseUrl/ingredient'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
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
      final response = await http.get(
        Uri.parse('$baseUrl/micronutrients'),
      );

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
      final token = await storage.read(key: 'access_token');
      
      final response = await http.get(
        Uri.parse('$baseUrl$path'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      print('DishesList error: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getDishInfo(String dishId) async {
    try {
      final token = await storage.read(key: 'access_token');
      
      final response = await http.get(
        Uri.parse('$baseUrl/dish/$dishId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('IngredientInfo error: $e');
      return null;
    }
  }

  Future<bool> addDish(Map<String, dynamic> dishData, XFile? image) async {
    try {
      final token = await storage.read(key: 'access_token');
      
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/dish'))
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['data'] = json.encode(dishData);
  
      if (image != null) {
      final bytes = await image.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
        ),
      );
    }

      final response = await request.send();

      return response.statusCode == 201;
    } catch (e) {
      print('Add dish error: $e');
      return false;
    }
  }

}