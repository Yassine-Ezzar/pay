import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String authBaseUrl = 'http://192.168.1.18:6000/api/auth';
  static const String cardBaseUrl = 'http://192.168.1.18:6000/api/cards';
  static const String braceletBaseUrl = 'http://192.168.1.18:6000/api/bracelets';
  static const String paymentBaseUrl = 'http://192.168.1.18:6000/api/payments';
  
  static const storage = FlutterSecureStorage();

  static Future<Map<String, dynamic>> register(String name, String pin, String securityAnswer, bool biometricEnabled) async {
    final response = await http.post(
      Uri.parse('$authBaseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'pin': pin, 'securityAnswer': securityAnswer, 'biometricEnabled': biometricEnabled}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await storage.write(key: 'token', value: data['token']);
      await storage.write(key: 'userId', value: data['userId'].toString()); // Stocke userId
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<Map<String, dynamic>> login(String name, String pin) async {
    final response = await http.post(
      Uri.parse('$authBaseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'pin': pin}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await storage.write(key: 'token', value: data['token']);
      await storage.write(key: 'userId', value: data['userId'].toString()); // Stocke userId
      await storage.write(key: 'name', value: name);
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<void> resetPin(String name, String securityAnswer, String newPin) async {
    final response = await http.post(
      Uri.parse('$authBaseUrl/reset-pin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'securityAnswer': securityAnswer, 'newPin': newPin}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message']);
    }
  }

static Future<Map<String, dynamic>> addCard(
    String userId,
    String cardNumber,
    String expiryDate,
    String cvv,
    String cardHolderName,
    String cardSecurityCode,
  ) async {
    final response = await http.post(
      Uri.parse('$cardBaseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'cardNumber': cardNumber,
        'expiryDate': expiryDate,
        'cvv': cvv,
        'cardHolderName': cardHolderName,
        'cardSecurityCode': cardSecurityCode,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<List<dynamic>> getCards(String userId) async {
    final response = await http.get(Uri.parse('$cardBaseUrl?userId=$userId'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<void> deleteCard(String cardId) async {
    final response = await http.delete(Uri.parse('$cardBaseUrl/$cardId'));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message']);
    }
  }

  static Future<Map<String, dynamic>> addBracelet(String userId, String braceletId, String name) async {
    final response = await http.post(
      Uri.parse('$braceletBaseUrl/add'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'userId': userId, 'braceletId': braceletId, 'name': name}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<Map<String, dynamic>> connectBracelet(String braceletId) async {
    final response = await http.post(
      Uri.parse('$braceletBaseUrl/connect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'braceletId': braceletId}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<Map<String, dynamic>> disconnectBracelet(String braceletId) async {
    final response = await http.post(
      Uri.parse('$braceletBaseUrl/disconnect'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'braceletId': braceletId}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<void> deleteBracelet(String braceletId) async {
    final response = await http.delete(Uri.parse('$braceletBaseUrl/$braceletId'));
    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['message']);
    }
  }

  static Future<List<dynamic>> getBracelets(String userId) async {
    final response = await http.get(Uri.parse('$braceletBaseUrl?userId=$userId'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message']);
  }

  // Payment-related methods
  static Future<Map<String, dynamic>> makePayment(String braceletId, String cardId, double amount, String merchant) async {
    final response = await http.post(
      Uri.parse('$paymentBaseUrl/make'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'braceletId': braceletId,
        'cardId': cardId,
        'amount': amount,
        'merchant': merchant,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<List<dynamic>> getPaymentHistory(String userId) async {
    final response = await http.get(Uri.parse('$paymentBaseUrl/history?userId=$userId'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message']);
  }
}