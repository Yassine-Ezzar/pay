import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.18:3000/api/auth';
  static const storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> register(String name, String pin, String securityAnswer, bool biometricEnabled) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'pin': pin, 'securityAnswer': securityAnswer, 'biometricEnabled': biometricEnabled}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await storage.write(key: 'token', value: data['token']);
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<Map<String, dynamic>> login(String name, String pin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'pin': pin}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await storage.write(key: 'token', value: data['token']);
      await storage.write(key: 'name', value: name);
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<void> resetPin(String name, String securityAnswer, String newPin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/reset-pin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'securityAnswer': securityAnswer, 'newPin': newPin}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message']);
    }
  }
}