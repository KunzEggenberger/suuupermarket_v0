import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Base URL of your backend server
  static const String baseUrl = 'https://suuupermarket.com'; // real backend server
  // Try using 'http://10.0.2.2:5000' for Android emulator
  // Use 'http://localhost:5000' for iOS simulator or web
  // For physical devices, use your computer's actual IP address

  // Store the session ID
  String? _sessionId;

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() {
    return _instance;
  }
  
  ApiService._internal();

  // Initialize the service and load session ID if available
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _sessionId = prefs.getString('sessionId');
  }

  // Get session ID
  String? get sessionId => _sessionId;

  // Set session ID and save to shared preferences
  Future<void> setSessionId(String? sessionId) async {
    _sessionId = sessionId;
    final prefs = await SharedPreferences.getInstance();
    if (sessionId != null) {
      await prefs.setString('sessionId', sessionId);
    } else {
      await prefs.remove('sessionId');
    }
  }

  // Check if user is authenticated
  bool get isAuthenticated => _sessionId != null;

  // Register a new user
  Future<String> registerUser(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/addUser'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to register user: ${response.body}');
    }
  }

  // Authenticate user
  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/authenticate'),
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await setSessionId(data['sessionId']);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    if (_sessionId != null) {
      try {
        await http.post(
          Uri.parse('$baseUrl/api/logout'),
          body: {'sessionId': _sessionId},
        );
      } catch (e) {
        print('Logout error: $e');
      }
    }
    await setSessionId(null);
  }

  // Get all marketplace listings
  Future<List<dynamic>> getListings() async {
    if (_sessionId == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/getListings?sessionId=$_sessionId'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load listings: ${response.body}');
    }
  }

  // Get user's crypto address
  Future<String> getCryptoAddress() async {
    if (_sessionId == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/getCryptoAddress?sessionId=$_sessionId'),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get crypto address: ${response.body}');
    }
  }

  // Get wallet balance
  Future<String> getBalance() async {
    if (_sessionId == null) {
      throw Exception('Not authenticated');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/getBalance?sessionId=$_sessionId'),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get balance: ${response.body}');
    }
  }

  // Validate session
  Future<bool> validateSession() async {
    if (_sessionId == null) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/validateSession?sessionId=$_sessionId'),
      );

      return response.statusCode == 200 && response.body.contains('valid');
    } catch (e) {
      print('Session validation error: $e');
      return false;
    }
  }
} 