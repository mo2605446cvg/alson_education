import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';

class ApiService {
  final SupabaseClient supabase = Supabase.instance.client;

  // دالة للتحقق من الاتصال
  Future<bool> checkConnection() async {
    try {
      final response = await supabase.from('users').select('count').limit(1).execute();
      return response.status == 200;
    } catch (e) {
      print('Connection error: $e');
      return false;
    }
  }

  Future<app_user.AppUser?> login(String code, String password) async {
    try {
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      final response = await supabase
          .from('users')
          .select()
          .eq('code', code)
          .eq('password', password)
          .single()
          .execute();

      if (response.status == 200 && response.data != null) {
        return app_user.AppUser.fromJson(response.data);
      } else {
        throw Exception('فشل في تسجيل الدخول: بيانات غير صحيحة');
      }
    } catch (e) {
      print('Login error: $e');
      throw Exception('فشل في تسجيل الدخول: $e');
    }
  }

  Future<List<Content>> getContent(String department, String division) async {
    try {
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      dynamic query;
      
      if (department.isNotEmpty && department != 'guest' && division.isNotEmpty && division != 'guest') {
        query = supabase
            .from('content')
            .select()
            .eq('department', department)
            .eq('division', division);
      } else if (department.isNotEmpty && department != 'guest') {
        query = supabase
            .from('content')
            .select()
            .eq('department', department);
      } else if (division.isNotEmpty && division != 'guest') {
        query = supabase
            .from('content')
            .select()
            .eq('division', division);
      } else {
        query = supabase
            .from('content')
            .select();
      }

      final response = await query.execute();

      if (response.status == 200 && response.data != null) {
        return (response.data as List).map((item) => Content.fromJson(item)).toList();
      } else {
        throw Exception('فشل في جلب المحتوى: ${response.status}');
      }
    } catch (e) {
      print('Get content error: $e');
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
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      // إنشاء اسم ملف فريد
      final fileExtension = file.path.split('.').last.toLowerCase();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${title.replaceAll(' ', '_')}.$fileExtension';
      
      // رفع الملف إلى Supabase Storage
      final uploadResponse = await supabase.storage
          .from('content')
          .upload(fileName, file, fileOptions: FileOptions(upsert: true));

      if (uploadResponse != null) {
        // الحصول على رابط الملف العام
        final fileUrl = supabase.storage
            .from('content')
            .getPublicUrl(fileName);

        // إضافة بيانات المحتوى إلى الجدول
        final response = await supabase.from('content').insert({
          'title': title,
          'file_path': fileUrl,
          'file_type': fileExtension,
          'file_size': file.lengthSync().toString(),
          'uploaded_by': uploadedBy,
          'department': department,
          'division': division,
          'description': description,
          'upload_date': DateTime.now().toIso8601String(),
        }).execute();

        return response.status == 201;
      } else {
        throw Exception('فشل في رفع الملف إلى التخزين');
      }
    } catch (e) {
      print('Upload content error: $e');
      throw Exception('فشل في رفع المحتوى: $e');
    }
  }

  Future<bool> deleteContent(String id, String department, String division) async {
    try {
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      final response = await supabase
          .from('content')
          .delete()
          .eq('id', id)
          .execute();

      return response.status == 204;
    } catch (e) {
      print('Delete content error: $e');
      throw Exception('فشل في حذف المحتوى: $e');
    }
  }

  Future<List<Message>> getChatMessages(String department, String division) async {
    try {
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      dynamic query;
      
      if (department.isNotEmpty && department != 'guest' && division.isNotEmpty && division != 'guest') {
        query = supabase
            .from('messages')
            .select('*, users(username)')
            .eq('department', department)
            .eq('division', division)
            .order('timestamp', ascending: true);
      } else if (department.isNotEmpty && department != 'guest') {
        query = supabase
            .from('messages')
            .select('*, users(username)')
            .eq('department', department)
            .order('timestamp', ascending: true);
      } else if (division.isNotEmpty && division != 'guest') {
        query = supabase
            .from('messages')
            .select('*, users(username)')
            .eq('division', division)
            .order('timestamp', ascending: true);
      } else {
        query = supabase
            .from('messages')
            .select('*, users(username)')
            .order('timestamp', ascending: true);
      }

      final response = await query.execute();

      if (response.status == 200 && response.data != null) {
        return (response.data as List).map((item) => Message.fromJson({
          'id': item['id'],
          'content': item['content'],
          'sender_id': item['sender_id'],
          'username': item['users']['username'],
          'department': item['department'],
          'division': item['division'],
          'timestamp': item['timestamp'],
        })).toList();
      } else {
        throw Exception('فشل في جلب الرسائل: ${response.status}');
      }
    } catch (e) {
      print('Get messages error: $e');
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
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      final response = await supabase.from('messages').insert({
        'content': content,
        'sender_id': senderId,
        'department': department,
        'division': division,
        'timestamp': DateTime.now().toIso8601String(),
      }).execute();

      return response.status == 201;
    } catch (e) {
      print('Send message error: $e');
      throw Exception('فشل في إرسال الرسالة: $e');
    }
  }

  Future<List<app_user.AppUser>> getUsers() async {
    try {
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      final response = await supabase
          .from('users')
          .select()
          .execute();

      if (response.status == 200 && response.data != null) {
        return (response.data as List).map((item) => app_user.AppUser.fromJson(item)).toList();
      } else {
        throw Exception('فشل في جلب المستخدمين: ${response.status}');
      }
    } catch (e) {
      print('Get users error: $e');
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
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      final response = await supabase.from('users').insert({
        'code': code,
        'username': username,
        'department': department,
        'division': division,
        'role': role,
        'password': password,
      }).execute();

      return response.status == 201;
    } catch (e) {
      print('Add user error: $e');
      throw Exception('فشل في إضافة المستخدم: $e');
    }
  }

  Future<bool> deleteUser(String code) async {
    try {
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      final response = await supabase
          .from('users')
          .delete()
          .eq('code', code)
          .execute();

      return response.status == 204;
    } catch (e) {
      print('Delete user error: $e');
      throw Exception('فشل في حذف المستخدم: $e');
    }
  }
}
