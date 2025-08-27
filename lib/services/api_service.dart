// ملف: api_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';

class ApiService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<User?> login(String code, String password) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('code', code)
          .eq('password', password)
          .single()
          .timeout(Duration(seconds: 10));

      if (response != null) {
        return User.fromJson(response);
      } else {
        throw Exception('فشل في تسجيل الدخول: بيانات غير صحيحة');
      }
    } catch (e) {
      throw Exception('فشل في تسجيل الدخول: $e');
    }
  }

  Future<List<Content>> getContent(String department, String division) async {
    try {
      var query = supabase.from('content').select();
      
      if (department.isNotEmpty && department != 'guest') {
        query = query.eq('department', department);
      }
      
      if (division.isNotEmpty && division != 'guest') {
        query = query.eq('division', division);
      }

      final response = await query.timeout(Duration(seconds: 10));

      return (response as List).map((item) => Content.fromJson(item)).toList();
    } catch (e) {
      throw Exception('فشل في جلب المحتوى: $e');
    }
  }

  Future<bool> uploadContent({
    required String title,
    required File file,
    required String uploadedBy,
    required String department,
    required String division,
    required String description,
  }) async {
    try {
      // رفع الملف إلى Supabase Storage
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final fileBytes = await file.readAsBytes();
      
      await supabase.storage
          .from('content')
          .uploadBinary(fileName, fileBytes);

      // الحصول على رابط الملف
      final fileUrl = supabase.storage
          .from('content')
          .getPublicUrl(fileName);

      // إضافة بيانات المحتوى إلى الجدول
      await supabase.from('content').insert({
        'title': title,
        'file_path': fileUrl,
        'file_type': file.path.split('.').last.toLowerCase(),
        'file_size': file.lengthSync().toString(),
        'uploaded_by': uploadedBy,
        'department': department,
        'division': division,
        'description': description,
        'upload_date': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('فشل في رفع المحتوى: $e');
    }
  }

  Future<bool> deleteContent(String id, String department, String division) async {
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

  Future<List<Message>> getChatMessages(String department, String division) async {
    try {
      var query = supabase
          .from('messages')
          .select('*, users(username)')
          .order('timestamp', ascending: true);

      if (department.isNotEmpty && department != 'guest') {
        query = query.eq('department', department);
      }
      
      if (division.isNotEmpty && division != 'guest') {
        query = query.eq('division', division);
      }

      final response = await query.timeout(Duration(seconds: 10));

      return (response as List).map((item) => Message.fromJson({
        'id': item['id'],
        'content': item['content'],
        'sender_id': item['sender_id'],
        'username': item['users']['username'],
        'department': item['department'],
        'division': item['division'],
        'timestamp': item['timestamp'],
      })).toList();
    } catch (e) {
      throw Exception('فشل في جلب الرسائل: $e');
    }
  }

  Future<bool> sendMessage({
    required String senderId,
    required String department,
    required String division,
    required String content,
  }) async {
    try {
      await supabase.from('messages').insert({
        'content': content,
        'sender_id': senderId,
        'department': department,
        'division': division,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (e) {
      throw Exception('فشل في إرسال الرسالة: $e');
    }
  }

  Future<List<User>> getUsers() async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .timeout(Duration(seconds: 10));

      return (response as List).map((item) => User.fromJson(item)).toList();
    } catch (e) {
      throw Exception('فشل في جلب المستخدمين: $e');
    }
  }

  Future<bool> addUser({
    required String code,
    required String username,
    required String department,
    required String division,
    required String role,
    required String password,
  }) async {
    try {
      await supabase.from('users').insert({
        'code': code,
        'username': username,
        'department': department,
        'division': division,
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