import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/lesson.dart';

class DatabaseService {
  static const String baseUrl = 'http://alalsunacademy.com/api/api.php';

  Future<List<User>> getUsers() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode} - ${response.body}');
    }
  }

  Future<User?> getUserByUsername(String username) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$username'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data != null ? User.fromMap(data) : null;
    } else {
      throw Exception('Failed to load user: ${response.statusCode} - ${response.body}');
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

  Future<List<Content>> getContents() async {
    final response = await http.get(Uri.parse('$baseUrl/content'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Content.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load content: ${response.statusCode} - ${response.body}');
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

  Future<List<Lesson>> getLessons() async {
    final response = await http.get(Uri.parse('$baseUrl/lessons'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Lesson.fromMap(json)).toList();
    } else {
      throw Exception('Failed to load lessons: ${response.statusCode} - ${response.body}');
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

  // الدالتين الجديدتين
  Future<void> updateUser(User user) async {
    final response = await http.put(
      Uri.parse('$baseUrl/users/${user.code}'), // افترض إن الكود هو الـ identifier
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
