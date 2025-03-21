import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  bool _isAuthenticated = false;
  String? _username;

  AuthProvider() {
    _loadAuthState();
  }

  bool get isAuthenticated => _isAuthenticated;
  String? get username => _username;

  Future<void> _loadAuthState() async {
    await _apiService.init();
    final prefs = await SharedPreferences.getInstance();
    _username = prefs.getString('currentUser');
    _isAuthenticated = await _apiService.validateSession();
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    final success = await _apiService.login(username, password);
    if (success) {
      _isAuthenticated = true;
      _username = username;
      
      // Save username to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('currentUser', username);
      
      notifyListeners();
    }
    return success;
  }

  Future<void> logout() async {
    await _apiService.logout();
    _isAuthenticated = false;
    _username = null;
    
    // Clear username from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentUser');
    
    notifyListeners();
  }

  Future<String> register(String username, String password) async {
    return await _apiService.registerUser(username, password);
  }
} 