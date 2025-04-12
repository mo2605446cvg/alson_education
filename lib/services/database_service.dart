import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/lesson.dart';
import 'package:alson_education/providers/app_state_provider.dart';

class DatabaseService {
  static const String baseUrl = 'http://srv1690.hstgr.io/api/api.php'; // يمكن تغييره لـ IP

  Future<List<User>> getUsers() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/users'));
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
      print("Fetching user with username: $username");
      final response = await http.get(Uri.parse('$baseUrl/users/$username'));
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
    final response = await http.post(
      Uri.parse('$baseUrl/users'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toMap()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to insert user: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Content>> getContents(String department) async { // فلترة بناءً على القسم
    try {
      final response = await http.get(Uri.parse('$baseUrl/content?department=$department'));
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
    final response = await http.post(
      Uri.parse('$baseUrl/content'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(content.toMap()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to insert content: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Lesson>> getLessons(String department) async { // فلترة بناءً على القسم
    try {
      final response = await http.get(Uri.parse('$baseUrl/lessons?department=$department'));
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
    final response = await http.post(
      Uri.parse('$baseUrl/lessons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(lesson.toMap()),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to insert lesson: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> toggleFavoriteLesson(String id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/lessons/$id/toggle'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to toggle favorite: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Lesson>> searchLessons(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/lessons/search?query=$query'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Lesson.fromMap(json)).toList();
    } else {
      throw Exception('Failed to search lessons: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${user.code}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toMap()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.statusCode} - ${response.body}');
    }
  }

  Future<void> deleteUser(String code) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/users/$code'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.statusCode} - ${response.body}');
    }
  }
}
