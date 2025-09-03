import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';

class ApiService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<bool> checkConnection() async {
    try {
      await supabase.from('users').select().limit(1);
      return true;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  Future<app_user.AppUser?> login(String code, String password) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('code', code)
          .eq('password', password)
          .single();

      return app_user.AppUser.fromJson(response);
    } catch (e) {
      throw Exception('فشل في تسجيل الدخول: بيانات غير صحيحة');
    }
  }

  Future<List<Content>> getContent() async {
    try {
      final response = await supabase
          .from('content')
          .select()
          .order('upload_date', ascending: false);

      return response.map((item) => Content.fromJson(item)).toList();
    } catch (e) {
      throw Exception('فشل في جلب المحتوى: $e');
    }
  }

  Future<bool> uploadContent({
    required String title,
    required String fileUrl,
    required String uploadedBy,
    required String description,
  }) async {
    try {
      await supabase.from('content').insert({
        'title': title,
        'file_path': fileUrl,
        'file_type': fileUrl.split('.').last.toLowerCase(),
        'file_size': '0',
        'uploaded_by': uploadedBy,
        'department': '',
        'division': '',
        'description': description,
        'upload_date': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('فشل في رفع المحتوى: $e');
    }
  }

  Future<bool> deleteContent(String id) async {
    try {
      await supabase
          .from('content')
          .delete()
          .eq('id', id);

      return true;
    } catch (e) {
      throw Exception('فشل في حذف المحتوى: $e');
    }
  }

// في قسم دوال المحادثة في api_service.dart
Future<List<Message>> getChatMessages() async {
  try {
    final response = await supabase
        .from('messages')
        .select()
        .order('timestamp', ascending: true);

    return response.map((item) => Message.fromJson(item)).toList();
  } catch (e) {
    throw Exception('فشل في جلب الرسائل: $e');
  }
}

Future<bool> sendMessage({
  required String senderId,
  required String content,
}) async {
  try {
    // التحقق من صلاحية المستخدم لإرسال الرسائل
    final userResponse = await supabase
        .from('users')
        .select('role')
        .eq('code', senderId)
        .single();

    final userRole = userResponse['role'];
    if (userRole != 'admin') {
      throw Exception('غير مسموح للمستخدمين العاديين بإرسال الرسائل');
    }

    await supabase.from('messages').insert({
      'content': content,
      'sender_id': senderId,
      'department': '',
      'division': '',
      'timestamp': DateTime.now().toIso8601String(),
    });

    return true;
  } catch (e) {
    throw Exception('فشل في إرسال الرسالة: $e');
  }
}

  Future<List<app_user.AppUser>> getUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select();

      return response.map((item) => app_user.AppUser.fromJson(item)).toList();
    } catch (e) {
      throw Exception('فشل في جلب المستخدمين: $e');
    }
  }

  Future<bool> addUser({
    required String code,
    required String username,
    required String role,
    required String password,
  }) async {
    try {
      await supabase.from('users').insert({
        'code': code,
        'username': username,
        'department': '',
        'division': '',
        'role': role,
        'password': password,
      });

      return true;
    } catch (e) {
      throw Exception('فشل في إضافة المستخدم: $e');
    }
  }

  Future<bool> deleteUser(String code) async {
    try {
      await supabase
          .from('users')
          .delete()
          .eq('code', code);

      return true;
    } catch (e) {
      throw Exception('فشل في حذف المستخدم: $e');
    }
  }
}