import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Replace with your actual server URL
  final String baseUrl = 'http://127.0.0.1/auth_api'; 
  // final String baseUrl = 'http://localhost/auth_api'; // Use this for iOS simulator
  // final String baseUrl = 'https://your-website.com/auth_api'; // Use this for production

  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['user'] != null) {
        // Save user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('user_id', data['user']['id']);
        await prefs.setString('user_name', data['user']['name']);
        await prefs.setString('user_email', data['user']['email']);
        await prefs.setBool('isLoggedIn', true);
      }

      return data;
    } catch (e) {
      return {'error': e.toString()};
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }
}