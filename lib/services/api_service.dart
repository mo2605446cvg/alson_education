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
      await supabase.from('users').select('count').limit(1);
      return true;
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
          .single();

      if (response != null) {
        return app_user.AppUser.fromJson(response);
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

      // جلب جميع المحتويات بدون تصفية بالقسم أو الشعبة
      final response = await supabase
          .from('content')
          .select()
          .order('upload_date', ascending: false);

      return response.map((item) => Content.fromJson(item)).toList();
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
      final fileName = 'content_${DateTime.now().millisecondsSinceEpoch}.$fileExtension';
      
      print('بدء رفع الملف: $fileName');

      // رفع الملف إلى Supabase Storage
      try {
        await supabase.storage
            .from('content')
            .upload(fileName, file);
        print('تم رفع الملف بنجاح');
      } catch (uploadError) {
        print('خطأ في رفع الملف: $uploadError');
        throw Exception('فشل في رفع الملف: $uploadError');
      }

      // الحصول على رابط الملف العام
      final fileUrl = supabase.storage
          .from('content')
          .getPublicUrl(fileName);

      print('رابط الملف: $fileUrl');

      // إضافة بيانات المحتوى إلى الجدول
      try {
        await supabase.from('content').insert({
          'title': title,
          'file_path': fileUrl,
          'file_type': fileExtension,
          'file_size': file.lengthSync().toString(),
          'uploaded_by': uploadedBy,
          'department': department,
          'division': division,
          'description': description,
          'upload_date': DateTime.now().toIso8601String(),
        });
        print('تم إضافة بيانات المحتوى إلى الجدول');
      } catch (dbError) {
        print('خطأ في إضافة البيانات: $dbError');
        throw Exception('فشل في إضافة البيانات: $dbError');
      }

      return true;
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

      await supabase
          .from('content')
          .delete()
          .eq('id', id);

      return true;
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

      // جلب جميع الرسائل بدون تصفية بالقسم أو الشعبة
      final response = await supabase
          .from('messages')
          .select('*, users(username)')
          .order('timestamp', ascending: true);

      return response.map((item) => Message.fromJson({
        'id': item['id'],
        'content': item['content'],
        'sender_id': item['sender_id'],
        'username': item['users']['username'],
        'department': item['department'] ?? '',
        'division': item['division'] ?? '',
        'timestamp': item['timestamp'],
      })).toList();
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

      await supabase.from('messages').insert({
        'content': content,
        'sender_id': senderId,
        'department': department,
        'division': division,
        'timestamp': DateTime.now().toIso8601String(),
      });

      return true;
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
          .select();

      return response.map((item) => app_user.AppUser.fromJson(item)).toList();
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
      print('Add user error: $e');
      throw Exception('فشل في إضافة المستخدم: $e');
    }
  }

  Future<bool> deleteUser(String code) async {
    try {
      if (!await checkConnection()) {
        throw Exception('فشل في الاتصال بالسيرفر');
      }

      await supabase
          .from('users')
          .delete()
          .eq('code', code);

      return true;
    } catch (e) {
      print('Delete user error: $e');
      throw Exception('فشل في حذف المستخدم: $e');
    }
  }
}
