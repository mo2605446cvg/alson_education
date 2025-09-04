import 'package:flutter/material.dart';
import 'package:alson_education/services/api_service.dart';

class ConnectionChecker {
  final ApiService apiService;

  ConnectionChecker(this.apiService);

  Future<bool> checkInternetConnection() async {
    try {
      final result = await apiService.checkSupabaseConnection();
      return result;
    } catch (e) {
      return false;
    }
  }

  void showConnectionError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 10),
            Text('فشل في الاتصال بالسيرفر. يرجى التحقق من الإنترنت'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 5),
      ),
    );
  }
}