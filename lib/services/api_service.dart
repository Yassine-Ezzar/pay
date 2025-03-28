import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String authBaseUrl = 'http://192.168.1.18:6000/api/auth';
  static const String cardBaseUrl = 'http://192.168.1.18:6000/api/cards';
  static const String braceletBaseUrl = 'http://192.168.1.18:6000/api/bracelets';
  static const String paymentBaseUrl = 'http://192.168.1.18:6000/api/payments';
  static const String locationBaseUrl = 'http://192.168.1.18:6000/api/locations';
  static const String profileBaseUrl = 'http://192.168.1.18:6000/api/profiles';
  
  
  static const storage = FlutterSecureStorage();

// Save profile to SharedPreferences
  static Future<void> saveProfileToLocal(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userProfile', jsonEncode(profile));
  }

  // Retrieve profile from SharedPreferences
  static Future<Map<String, dynamic>?> getProfileFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final profileString = prefs.getString('userProfile');
    if (profileString != null) {
      return jsonDecode(profileString) as Map<String, dynamic>;
    }
    return null;
  }

  // Clear profile from SharedPreferences (for new user registration)
  static Future<void> clearProfileFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userProfile');
  }

  static Future<Map<String, dynamic>> register(String name, String pin, String securityAnswer, bool biometricEnabled) async {
    final response = await http.post(
      Uri.parse('$authBaseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'pin': pin, 'securityAnswer': securityAnswer, 'biometricEnabled': biometricEnabled}),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await storage.write(key: 'token', value: data['token']);
      await storage.write(key: 'userId', value: data['userId'].toString());
      await clearProfileFromLocal(); 
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
      final cardId = data['card']['_id'];
      await storage.write(key: 'cardSecurityCode_$cardId', value: cardSecurityCode);
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<String?> getCardSecurityCode(String cardId) async {
    return await storage.read(key: 'cardSecurityCode_$cardId');
  }

  static Future<void> deleteCardSecurityCode(String cardId) async {
    await storage.delete(key: 'cardSecurityCode_$cardId');
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
    if (response.statusCode == 200) {
      await deleteCardSecurityCode(cardId);
    } else {
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

  static Future<Map<String, dynamic>> makePayment(String braceletId, String cardId, double amount, String merchant) async {
    final cardSecurityCode = await getCardSecurityCode(cardId);
    if (cardSecurityCode == null) {
      throw Exception('Card security code not found. Please add the card again.');
    }

    final response = await http.post(
      Uri.parse('$paymentBaseUrl/make'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'braceletId': braceletId,
        'cardId': cardId,
        'amount': amount,
        'merchant': merchant,
        'cardSecurityCode': cardSecurityCode, 
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




  static Future<Map<String, dynamic>> updateBraceletLocation(String braceletId, double latitude, double longitude) async {
    final response = await http.post(
      Uri.parse('$locationBaseUrl/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'braceletId': braceletId,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<Map<String, dynamic>> getBraceletLocation(String braceletId) async {
    final response = await http.get(Uri.parse('$locationBaseUrl?braceletId=$braceletId'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message']);
  }

static Future<Map<String, dynamic>> createProfile({
    required String userId,
    required String fullName,
    required String email,
    String? nickname,
    String? phoneNumber,
    String? country,
    String? gender,
    String? address,
  }) async {
    final response = await http.post(
      Uri.parse('$profileBaseUrl/create'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'fullName': fullName,
        'nickname': nickname,
        'email': email,
        'phoneNumber': phoneNumber,
        'country': country,
        'gender': gender,
        'address': address,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 201) {
      await saveProfileToLocal(data['profile']); 
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<Map<String, dynamic>> getProfile(String userId) async {
    final localProfile = await getProfileFromLocal();
    if (localProfile != null) {
      return localProfile;
    }

    final response = await http.get(Uri.parse('$profileBaseUrl?userId=$userId'));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await saveProfileToLocal(data);
      return data;
    }
    throw Exception(data['message']);
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String fullName,
    required String email,
    String? nickname,
    String? phoneNumber,
    String? country,
    String? gender,
    String? address,
  }) async {
    final response = await http.put(
      Uri.parse('$profileBaseUrl/update'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'fullName': fullName,
        'nickname': nickname,
        'email': email,
        'phoneNumber': phoneNumber,
        'country': country,
        'gender': gender,
        'address': address,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      await saveProfileToLocal(data['profile']); 
      return data;
    }
    throw Exception(data['message']);
  }
}