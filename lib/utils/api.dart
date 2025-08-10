
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';
import 'package:alson_education/models/user.dart';

const String baseUrl = 'http://ki74.alalsunacademy.com/api.php';

Future<User?> loginUser(String code, String password) async {
  final client = http.Client();
  try {
    final request = http.Request('POST', Uri.parse('$baseUrl?table=users&action=login'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({'code': code, 'password': password});

    final response = await client.send(request).then((res) => http.Response.fromStream(res));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        return User.fromJson(data['user']);
      } else {
        throw Exception('Invalid credentials');
      }
    } else if (response.statusCode == 301 || response.statusCode == 302) {
      final newUrl = response.headers['location'];
      if (newUrl != null) {
        final retryResponse = await client.post(
          Uri.parse(newUrl),
          body: jsonEncode({'code': code, 'password': password}),
          headers: {'Content-Type': 'application/json'},
        );
        if (retryResponse.statusCode == 200) {
          final data = jsonDecode(retryResponse.body);
          if (data['success'] == true) {
            return User.fromJson(data['user']);
          } else {
            throw Exception('Invalid credentials after redirect');
          }
        } else {
          throw Exception('Failed to login after redirect: ${retryResponse.statusCode}');
        }
      } else {
        throw Exception('Redirect location not found');
      }
    } else {
      throw Exception('Failed to login: ${response.statusCode}');
    }
  } catch (e) {
    print('Error logging in: $e');
    throw Exception('Failed to login: $e');
  } finally {
    client.close();
  }
}

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

Future<void> uploadContent(Content content, String filePath) async {
  try {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl?table=content'));
    request.fields['title'] = content.title;
    request.fields['description'] = content.description;
    request.fields['file_type'] = content.fileType;
    request.fields['uploaded_by'] = content.uploadedBy;
    request.fields['upload_date'] = content.uploadDate;
    request.files.add(await http.MultipartFile.fromPath('file', filePath));
    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to upload content: ${response.statusCode}');
    }
  } catch (e) {
    print('Error uploading content: $e');
    throw Exception('Failed to upload content: $e');
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

Future<void> sendMessage(String userCode, String messageText) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl?table=messages'),
      body: jsonEncode({'user_code': userCode, 'message': messageText}),
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

Future<void> addUser(User user, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl?table=users'),
      body: jsonEncode({
        'code': user.code,
        'name': user.name,
        'password': password,
        'role': user.role,
      }),
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
