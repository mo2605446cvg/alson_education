import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';

class ApiService {
  static const String baseUrl = "https://ki74.alalsunacademy.com/api";
  
  Future<User?> login(String code, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api.php?table=users&action=login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code, 'password': password}),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        return User.fromJson(userData);
      } else {
        throw Exception('فشل في تسجيل الدخول: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في الاتصال بالسيرفر: $e');
    }
  }

  Future<List<Content>> getContent(String department, String division) async {
    try {
      String url = '$baseUrl/api.php?table=content';
      if (department.isNotEmpty && division.isNotEmpty) {
        url += '&department=$department&division=$division';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Content.fromJson(item)).toList();
      } else {
        throw Exception('فشل في جلب المحتوى: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في الاتصال بالسيرفر: $e');
    }
  }

  Future<bool> uploadContent({
    required String title,
    required File file,
    required String uploadedBy,
    required String department,
    required String division,
    required String description,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload.php'),
      );

      // إضافة الحقول النصية
      request.fields['title'] = title;
      request.fields['uploaded_by'] = uploadedBy;
      request.fields['department'] = department;
      request.fields['division'] = division;
      request.fields['description'] = description;

      // إضافة الملف
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        file.path,
        filename: file.path.split('/').last,
      ));

      final response = await request.send().timeout(Duration(seconds: 30));
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final result = json.decode(responseData);
        return result['success'] == true;
      } else {
        throw Exception('فشل في رفع المحتوى: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في رفع المحتوى: $e');
    }
  }

  Future<bool> deleteContent(String id, String department, String division) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api.php?table=content'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'id': id}),
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('فشل في حذف المحتوى: $e');
    }
  }

  Future<List<Message>> getChatMessages(String department, String division) async {
    try {
      String url = '$baseUrl/api.php?table=messages';
      if (department.isNotEmpty && division.isNotEmpty) {
        url += '&department=$department&division=$division';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Message.fromJson(item)).toList();
      } else {
        throw Exception('فشل في جلب الرسائل: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في الاتصال بالسيرفر: $e');
    }
  }

  Future<bool> sendMessage({
    required String senderId,
    required String department,
    required String division,
    required String content,
  }) async {
    try {
      final timestamp = DateTime.now().toString();
      final id = DateTime.now().millisecondsSinceEpoch.toString();

      final response = await http.post(
        Uri.parse('$baseUrl/api.php?table=messages'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'content': content,
          'sender_id': senderId,
          'department': department,
          'division': division,
          'timestamp': timestamp,
        }),
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('فشل في إرسال الرسالة: $e');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api.php?table=users&action=all'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => User.fromJson(item)).toList();
      } else {
        throw Exception('فشل في جلب المستخدمين: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('فشل في الاتصال بالسيرفر: $e');
    }
  }

  Future<bool> addUser({
    required String code,
    required String username,
    required String department,
    required String division,
    required String role,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api.php?table=users&action=add'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'code': code,
          'username': username,
          'department': department,
          'division': division,
          'role': role,
          'password': password,
        }),
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('فشل في إضافة المستخدم: $e');
    }
  }

  Future<bool> deleteUser(String code) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api.php?table=users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'code': code}),
      ).timeout(Duration(seconds: 10));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('فشل في حذف المستخدم: $e');
    }
  }
}