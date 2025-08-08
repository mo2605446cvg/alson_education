import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/models/user.dart';

const String apiUrl = 'http://ki74.alalsunacademy.com/api';

void initializeNotifications() async {
  if (!kIsWeb) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alson-academy-channel',
      'Alson Academy Notifications',
      description: 'Default channel for notifications',
      importance: Importance.max,
    );
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }
}

void scheduleNotification(String title, String body) async {
  if (!kIsWeb) {
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'alson-academy-channel',
      'Alson Academy Notifications',
      channelDescription: 'Default channel for notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
    );
  } else {
    print('Notifications are not supported on web.');
  }
}

Future<User> loginUser(String code, String password) async {
  var connectivityResult = await (Connectivity().checkConnectivity());
  if (connectivityResult == ConnectivityResult.none) {
    throw Exception('لا يوجد اتصال بالإنترنت');
  }

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
    throw Exception('Failed to login: $error');
  }
}

Future<List<User>> getUsers() async {
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api.php?table=users&action=all'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users: ${response.body}');
    }
  } catch (error) {
    print('Error in getUsers: $error');
    throw Exception('Failed to fetch users: $error');
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
    if (response.statusCode != 200) {
      throw Exception('Failed to add user: ${response.body}');
    }
  } catch (error) {
    print('Error in addUser: $error');
    throw Exception('Failed to add user: $error');
  }
}

Future<void> deleteUser(String code) async {
  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/api.php?table=users&action=delete'),
      body: jsonEncode({'code': code}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.body}');
    }
  } catch (error) {
    print('Error in deleteUser: $error');
    throw Exception('Failed to delete user: $error');
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
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Content.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch content: ${response.body}');
    }
  } catch (error) {
    print('Error in getContent: $error');
    throw Exception('Failed to fetch content: $error');
  }
}

Future<void> uploadContent(String title, PlatformFile file, String uploadedBy, String department, String division) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/upload.php'));
    request.fields['data'] = jsonEncode({
      'title': title,
      'uploaded_by': uploadedBy,
      'department': department,
      'division': division,
    });
    request.files.add(await http.MultipartFile.fromPath('file', file.path!));
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload content: $responseBody');
    }
  } catch (error) {
    print('Error in uploadContent: $error');
    throw Exception('Failed to upload content: $error');
  }
}

Future<void> deleteContent(String id) async {
  try {
    final response = await http.delete(
      Uri.parse('$apiUrl/api.php?table=content'),
      body: jsonEncode({'id': id}),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete content: ${response.body}');
    }
  } catch (error) {
    print('Error in deleteContent: $error');
    throw Exception('Failed to delete content: $error');
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
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch messages: ${response.body}');
    }
  } catch (error) {
    print('Error in getChatMessages: $error');
    throw Exception('Failed to fetch messages: $error');
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
    if (response.statusCode == 200) {
      scheduleNotification('رسالة جديدة', 'رسالة جديدة في الشات: ${content.substring(0, 50)}...');
    } else {
      throw Exception('Failed to send message: ${response.body}');
    }
  } catch (error) {
    print('Error in sendMessage: $error');
    throw Exception('Failed to send message: $error');
  }
}

class Result {
  final double score;
  final String subject;
  final String date;

  Result({
    required this.score,
    required this.subject,
    required this.date,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      score: (json['score'] as num).toDouble(),
      subject: json['subject'] as String,
      date: json['date'] as String,
    );
  }
}

Future<Result> getResults(String studentId) async {
  try {
    final response = await http.get(
      Uri.parse('$apiUrl/api.php?table=results&studentId=$studentId'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return Result.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch results: ${response.body}');
    }
  } catch (error) {
    print('Error in getResults: $error');
    throw Exception('Failed to fetch results: $error');
  }
}
