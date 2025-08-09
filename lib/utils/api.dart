import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';
import 'dart:io';

const String apiUrl = 'http://ki74.alalsunacademy.com/api';

Future<User> loginUser(String code, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$apiUrl/api.php?table=users&action=login'),
      body: jsonEncode({'code': code, 'password': password}),
      headers: {'Content-Type': 'application/json'},
    );
    print('Login Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  } catch (error) {
    print('Error in loginUser: $error');
    throw Exception('فشل تسجيل الدخول: تأكد من الاتصال بالإنترنت');
  }
}

Future<List<User>> getUsers() async {
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api.php?table=users&action=all'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Get Users Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  } catch (error) {
    print('Error in getUsers: $error');
    throw Exception('فشل في جلب المستخدمين: $error');
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
    );
    print('Add User Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to add user: ${response.body}');
    }
  } catch (error) {
    print('Error in addUser: $error');
    throw Exception('فشل في إضافة المستخدم: $error');
  }
}

Future<void> deleteUser(String code) async {
  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/api.php?table=users&action=delete'),
      body: jsonEncode({'code': code}),
      headers: {'Content-Type': 'application/json'},
    );
    print('Delete User Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  } catch (error) {
    print('Error in deleteUser: $error');
    throw Exception('فشل في حذف المستخدم: $error');
  }
}

Future<List<Content>> getContent(String department, String division) async {
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api.php?table=content&department=$department&division=$division'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Get Content Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Content.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch content: ${response.body}');
    }
  } catch (error) {
    print('Error in getContent: $error');
    throw Exception('فشل في جلب المحتوى: $error');
  }
}

Future<void> uploadContent(String title, File file, String uploadedBy, String department, String division) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/upload.php'));
    request.fields['data'] = jsonEncode({
      'title': title,
      'uploaded_by': uploadedBy,
      'department': department,
      'division': division,
    });
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    print('Upload Content Response: ${response.statusCode} - $responseBody');
    if (response.statusCode != 200) {
      throw Exception('Failed to upload content: $responseBody');
    }
  } catch (error) {
    print('Error in uploadContent: $error');
    throw Exception('فشل في رفع المحتوى: $error');
  }
}

Future<void> deleteContent(String id) async {
  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/api.php?table=content'),
      body: jsonEncode({'id': id}),
      headers: {'Content-Type': 'application/json'},
    );
    print('Delete Content Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to delete content: ${response.body}');
    }
  } catch (error) {
    print('Error in deleteContent: $error');
    throw Exception('فشل في حذف المحتوى: $error');
  }
}

Future<List<Message>> getChatMessages(String department, String division) async {
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api.php?table=messages&department=$department&division=$division'),
      headers: {'Content-Type': 'application/json'},
    );
    print('Get Messages Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch messages: ${response.body}');
    }
  } catch (error) {
    print('Error in getChatMessages: $error');
    throw Exception('فشل في جلب الرسائل: $error');
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
    );
    print('Send Message Response: ${response.statusCode} - ${response.body}');
    if (response.statusCode != 200) {
      throw Exception('Failed to send message: ${response.body}');
    }
  } catch (error) {
    print('Error in sendMessage: $error');
    throw Exception('فشل في إرسال الرسالة: $error');
  }
}