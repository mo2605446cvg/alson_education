import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http/io_client.dart' as io_client;
import 'dart:io';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/lesson.dart';
import 'package:alson_education/providers/app_state_provider.dart';

class DatabaseService {
  static const String baseUrl = 'https://alalsunacademy.com/api/api.php'; // استخدام HTTPS

  static Future<http.Client> getClient() async {
    final client = io_client.IOClient(
      HttpClient()..badCertificateCallback = (cert, host, port) => true, // تجاوز شهادات غير موثوقة مؤقتًا
    );
    return client;
  }

  Future<List<User>> getUsers() async {
    try {
      final client = await getClient();
      final response = await client.get(Uri.parse('$baseUrl/users')).timeout(const Duration(seconds: 10));
      print("GET Users response: Status ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => User.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in getUsers: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<User?> getUserByUsername(String username) async {
    try {
      final client = await getClient();
      print("Fetching user with username: $username");
      final response = await client.get(Uri.parse('$baseUrl/users/$username')).timeout(const Duration(seconds: 10));
      print("GET User response: Status ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data != null ? User.fromMap(data) : null;
      } else {
        throw Exception('Failed to load user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in getUserByUsername: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<void> insertUser(User user) async {
    try {
      final client = await getClient();
      final response = await client.post(
        Uri.parse('$baseUrl/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toMap()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to insert user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in insertUser: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<List<Content>> getContents(String department) async {
    try {
      final client = await getClient();
      final response = await client.get(Uri.parse('$baseUrl/content?department=$department')).timeout(const Duration(seconds: 10));
      print("GET Contents response: Status ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Content.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load content: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in getContents: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<void> insertContent(Content content) async {
    try {
      final client = await getClient();
      final response = await client.post(
        Uri.parse('$baseUrl/content'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(content.toMap()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to insert content: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in insertContent: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<List<Lesson>> getLessons(String department) async {
    try {
      final client = await getClient();
      final response = await client.get(Uri.parse('$baseUrl/lessons?department=$department')).timeout(const Duration(seconds: 10));
      print("GET Lessons response: Status ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Lesson.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load lessons: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in getLessons: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<void> insertLesson(Lesson lesson) async {
    try {
      final client = await getClient();
      final response = await client.post(
        Uri.parse('$baseUrl/lessons'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(lesson.toMap()),
      );
      if (response.statusCode != 201) {
        throw Exception('Failed to insert lesson: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in insertLesson: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<void> toggleFavoriteLesson(String id) async {
    try {
      final client = await getClient();
      final response = await client.put(
        Uri.parse('$baseUrl/lessons/$id/toggle'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to toggle favorite: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in toggleFavoriteLesson: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<List<Lesson>> searchLessons(String query) async {
    try {
      final client = await getClient();
      final response = await client.get(Uri.parse('$baseUrl/lessons/search?query=$query'));
      print("GET Search Lessons response: Status ${response.statusCode}, Body: ${response.body}");
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Lesson.fromMap(json)).toList();
      } else {
        throw Exception('Failed to search lessons: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in searchLessons: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateUser(User user) async {
    try {
      final client = await getClient();
      final response = await client.put(
        Uri.parse('$baseUrl/users/${user.code}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toMap()),
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in updateUser: $e");
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteUser(String code) async {
    try {
      final client = await getClient();
      final response = await client.delete(
        Uri.parse('$baseUrl/users/$code'),
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to delete user: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print("Network error in deleteUser: $e");
      throw Exception('Network error: $e');
    }
  }
}
