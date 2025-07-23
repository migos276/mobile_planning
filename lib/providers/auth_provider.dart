import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  bool _isFirstTime = true;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isFirstTime => _isFirstTime;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    _loadUserFromStorage();
  }

  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('current_user');
      final firstTime = prefs.getBool('is_first_time') ?? true;
      
      _isFirstTime = firstTime;
      
      if (userJson != null) {
        final userMap = json.decode(userJson);
        _currentUser = User.fromJson(userMap);
      }
    } catch (e) {
      debugPrint('Error loading user from storage: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> signUp(String name, String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        joinDate: DateTime.now(),
      );

      _currentUser = user;
      await _saveUserToStorage(user);
      await _setFirstTime(false);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock user for demo
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Utilisatrice Demo',
        email: email,
        joinDate: DateTime.now().subtract(const Duration(days: 30)),
        successCount: 15,
        completedTasks: 42,
        badges: ['first-success', 'week-warrior', 'confidence-builder'],
        confidenceLevel: 3,
      );

      _currentUser = user;
      await _saveUserToStorage(user);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    notifyListeners();
  }

  Future<void> _saveUserToStorage(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toJson());
    await prefs.setString('current_user', userJson);
  }

  Future<void> _setFirstTime(bool isFirstTime) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_time', isFirstTime);
    _isFirstTime = isFirstTime;
  }

  Future<void> completeOnboarding() async {
    await _setFirstTime(false);
    notifyListeners();
  }
}