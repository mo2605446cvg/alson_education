import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';
import 'package:alson_education/models/user.dart';

const String baseUrl = 'http://ki74.alalsunacademy.com/api.php';

Future<List<Content>> getContent() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl?table=content'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Content.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load content: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching content: $e');
    throw Exception('Failed to load content: $e');
  }
}

Future<void> addContent(Content content) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl?table=content'),
      body: jsonEncode(content.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add content: ${response.statusCode}');
    }
  } catch (e) {
    print('Error adding content: $e');
    throw Exception('Failed to add content: $e');
  }
}

Future<void> deleteContent(String id) async {
  try {
    final response = await http.delete(Uri.parse('$baseUrl?table=content&id=$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete content: ${response.statusCode}');
    }
  } catch (e) {
    print('Error deleting content: $e');
    throw Exception('Failed to delete content: $e');
  }
}

Future<List<Message>> getMessages() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl?table=messages'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Message.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load messages: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching messages: $e');
    throw Exception('Failed to load messages: $e');
  }
}

Future<void> sendMessage(Message message) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl?table=messages'),
      body: jsonEncode(message.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  } catch (e) {
    print('Error sending message: $e');
    throw Exception('Failed to send message: $e');
  }
}

Future<List<User>> getUsers() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl?table=users'));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching users: $e');
    throw Exception('Failed to load users: $e');
  }
}

Future<void> addUser(User user) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl?table=users'),
      body: jsonEncode(user.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add user: ${response.statusCode}');
    }
  } catch (e) {
    print('Error adding user: $e');
    throw Exception('Failed to add user: $e');
  }
}

Future<void> deleteUser(String id) async {
  try {
    final response = await http.delete(Uri.parse('$baseUrl?table=users&id=$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete user: ${response.statusCode}');
    }
  } catch (e) {
    print('Error deleting user: $e');
    throw Exception('Failed to delete user: $e');
  }
}