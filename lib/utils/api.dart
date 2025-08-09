import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alson_education/models/user.dart';
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
      Uri.parse('$apiUrl/api.php?table=users&action=delete'),
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

class Content {
  final String id;
  final String title;
  final String filePath;
  final String fileType;
  final String uploadedBy;
  final String uploadDate;

  Content({
    required this.id,
    required this.title,
    required this.filePath,
    required this.fileType,
    required this.uploadedBy,
    required this.uploadDate,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      id: json['id'] as String,
      title: json['title'] as String,
      filePath: json['file_path'] as String,
      fileType: json['file_type'] as String,
      uploadedBy: json['uploaded_by'] as String,
      uploadDate: json['upload_date'] as String,
    );
  }
}

Future<List<Content>> getContent(String department, String division) async {
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api.php?table=content&department=$department&division=$division'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
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

Future<void> uploadContent(String title, File file, String uploadedBy, String department, String division) async {
  try {
    if (!file.existsSync()) {
      throw Exception('الملف غير موجود');
    }
    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/upload.php'));
    request.fields['data'] = jsonEncode({
      'title': title,
      'uploaded_by': uploadedBy,
      'department': department,
      'division': division,
    });
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      await file.readAsBytes(),
      filename: file.path.split('/').last,
    ));
    final response = await request.send().timeout(const Duration(seconds: 30));
    final responseBody = await response.stream.bytesToString();
    print('Upload Content Response: ${response.statusCode} - $responseBody');
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

class Message {
  final String id;
  final String username;
  final String content;
  final String timestamp;

  Message({
    required this.id,
    required this.username,
    required this.content,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      username: json['username'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as String,
    );
  }
}

Future<List<Message>> getChatMessages(String department, String division) async {
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api.php?table=messages&department=$department&division=$division'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 10));
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
