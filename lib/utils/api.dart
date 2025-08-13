import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';
import 'dart:io';

const String apiUrl = 'https://ki74.alalsunacademy.com/api';

Future<User> loginUser(String code, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api.php?table=users&action=login'),
      body: jsonEncode({'code': code, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    print('Login Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('فشل تسجيل الدخول: كود الخطأ ${response.statusCode}');
    }
  } catch (error) {
    print('Error in loginUser: $error');
    throw Exception('فشل في الاتصال بالسيرفر: تأكد من الإنترنت');
  }
}

Future<List<User>> getUsers() async {
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api.php?table=users&action=all'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    print('Get Users Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('فشل في جلب المستخدمين: كود الخطأ ${response.statusCode}');
    }
  } catch (error) {
    print('Error in getUsers: $error');
    throw Exception('فشل في الاتصال بالسيرفر: تأكد من الإنترنت');
  }
}

Future<void> addUser(User user, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api.php?table=users&action=add'),
      body: jsonEncode({
        'code': user.code,
        'username': user.username,
        'department': user.department,
        'division': user.division,
        'role': user.role,
        'password': password,
      }),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    print('Add User Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('فشل في إضافة المستخدم: كود الخطأ ${response.statusCode}');
    }
  } catch (error) {
    print('Error in addUser: $error');
    throw Exception('فشل في الاتصال بالسيرفر: تأكد من الإنترنت');
  }
}

Future<void> deleteUser(String code) async {
  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/api.php?table=users'),
      body: jsonEncode({'code': code}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    print('Delete User Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('فشل في حذف المستخدم: كود الخطأ ${response.statusCode}');
    }
  } catch (error) {
    print('Error in deleteUser: $error');
    throw Exception('فشل في الاتصال بالسيرفر: تأكد من الإنترنت');
  }
}

Future<List<Content>> getContent(String department, String division) async {
  try {
    final uri = Uri.parse('$apiUrl/api.php?table=content${department.isEmpty ? '' : '&department=$department'}${division.isEmpty ? '' : '&division=$division'}');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 10));
    print('Get Content Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Content.fromJson(json)).toList();
    } else {
      throw Exception('فشل في جلب المحتوى: كود الخطأ ${response.statusCode}');
    }
  } catch (error) {
    print('Error in getContent: $error');
    throw Exception('فشل في الاتصال بالسيرفر: تأكد من الإنترنت');
  }
}

Future<void> uploadContent(String title, File file, String uploadedBy, String department, String division, String description) async {
  try {
    final request = http.MultipartRequest('POST', Uri.parse('$apiUrl/upload.php'));
    request.fields['data'] = jsonEncode({
      'title': title,
      'uploaded_by': uploadedBy,
      'department': department,
      'division': division,
      'description': description,
    });
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send().timeout(const Duration(seconds: 10));
    print('Upload Content Response: ${response.statusCode}');
    if (response.statusCode != 200) {
      throw Exception('فشل في رفع المحتوى: كود الخطأ ${response.statusCode}');
    }
  } catch (error) {
    print('Error in uploadContent: $error');
    throw Exception('فشل في الاتصال بالسيرفر أو رفع الملف: تأكد من الإنترنت');
  }
}

Future<void> deleteContent(String id) async {
  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/api.php?table=content'),
      body: jsonEncode({'id': id}),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    print('Delete Content Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('فشل في حذف المحتوى: كود الخطأ ${response.statusCode}');
    }
  } catch (error) {
    print('Error in deleteContent: $error');
    throw Exception('فشل في الاتصال بالسيرفر: تأكد من الإنترنت');
  }
}

Future<List<Message>> getChatMessages(String department, String division) async {
  try {
    final uri = Uri.parse('$apiUrl/api.php?table=messages${department.isEmpty ? '' : '&department=$department'}${division.isEmpty ? '' : '&division=$division'}');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'}).timeout(const Duration(seconds: 10));
    print('Get Messages Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('فشل في جلب الرسائل: كود الخطأ ${response.statusCode}');
    }
  } catch (error) {
    print('Error in getChatMessages: $error');
    throw Exception('فشل في الاتصال بالسيرفر: تأكد من الإنترنت');
  }
}

Future<void> sendMessage(String senderId, String department, String division, String content) async {
  try {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = DateTime.now().toIso8601String();
    final response = await http.post(
      Uri.parse('$apiUrl/api.php?table=messages'),
      body: jsonEncode({
        'id': id,
        'content': content,
        'sender_id': senderId,
        'department': department,
        'division': division,
        'timestamp': timestamp,
      }),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    print('Send Message Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('فشل في إرسال الرسالة: كود الخطأ ${response.statusCode}');
    }
  } catch (error) {
    print('Error in sendMessage: $error');
    throw Exception('فشل في الاتصال بالسيرفر: تأكد من الإنترنت');
  }
}
