
import 'package:flutter/material.dart';
import 'package:alson_education/models/user.dart';

class UserProvider with ChangeNotifier {
  User? _user;

  User? get user => _user;

  void login(User userData) {
    _user = userData;
    notifyListeners();
  }

  void logout() {
    _user = null;
    notifyListeners();
  }
}
