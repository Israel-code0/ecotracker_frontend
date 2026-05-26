import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://ecotrackerbackend-production.up.railway.app/api/auth',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 3),
));

  String? _token;
  String? _userId;
  String? _userName;
  bool _isLoading = false;
  String? _errorMessage;

  String? get token => _token;
  String? get userId => _userId;
  String? get userName => _userName;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null;


  /// Auto-Login Sequence: Reads disk storage on app boot
  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) return false;

    _token = prefs.getString('token');
    _userId = prefs.getString('userId');
    _userName = prefs.getString('userName');
    
    notifyListeners();
    return true;
  }

  /// Sends login credentials to Spring Boot
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        _token = response.data['token'];
        _userId = response.data['userId'];
        _userName = response.data['name'];

        // 2. Persist to disk memory
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userId', _userId!);
        await prefs.setString('userName', _userName!);
        return true;
      }
      return false;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?.toString() ?? "Invalid credentials. Please try again.";
      return false;
    } catch (e) {
      _errorMessage = "Connection refused. Is the backend server running?";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sends registration fields to Spring Boot
  Future<bool> signup(String name, String email, String password, double annualGoal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _dio.post('/signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'annualCarbonGoal': annualGoal,
      });

      if (response.statusCode == 200) {
        _token = response.data['token'];
        _userId = response.data['userId'];
        _userName = response.data['name'];

        // Persist to disk memory
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('userId', _userId!);
        await prefs.setString('userName', _userName!);
        return true;
      }
      return false;
    } on DioException catch (e) {
      _errorMessage = e.response?.data?.toString() ?? "Registration failed.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear session state to log out
 Future<void> logout() async {
    _token = null;
    _userId = null;
    _userName = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');

    notifyListeners();
  }
}