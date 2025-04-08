import 'package:flutter/material.dart';

class AppState with ChangeNotifier {
  String? _currentUserEmail;
  String? _currentUserCode;
  String? _currentUserRole;
  String? _currentUserDepartment;
  bool _isLoading = false;
  String _language = 'ar';
  bool _hasError = false;
  String? _errorMessage;

  String? get currentUserEmail => _currentUserEmail;
  String? get currentUserCode => _currentUserCode;
  String? get currentUserRole => _currentUserRole;
  String? get currentUserDepartment => _currentUserDepartment;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUserRole == 'admin';
  String get language => _language;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;

  void login(String email, String code, String role, String department) {
    _currentUserEmail = email;
    _currentUserCode = code;
    _currentUserRole = role;
    _currentUserDepartment = department;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _currentUserEmail = null;
    _currentUserCode = null;
    _currentUserRole = null;
    _currentUserDepartment = null;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  void setError(String? message) {
    _hasError = message != null;
    _errorMessage = message;
    notifyListeners();
  }
}
