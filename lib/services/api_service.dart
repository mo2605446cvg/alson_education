import 'dart:async'; // أضف هذا السطر
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';

class ApiService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<bool> checkSupabaseConnection() async {
    try {
      try {
        final internetResult = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 10));
        if (internetResult.isEmpty) {
          return false;
        }
      } catch (e) {
        print('❌ لا يوجد اتصال بالإنترنت: $e');
        return false;
      }

      final session = supabase.auth.currentSession;
      
      try {
        final testResponse = await supabase
            .from('users')
            .select()
            .limit(1)
            .timeout(const Duration(seconds: 10));

        return testResponse.isNotEmpty;
      } catch (e) {
        print('❌ فشل اختبار الاتصال بـ Supabase: $e');
        
        try {
          await Supabase.instance.dispose();
          await Supabase.initialize(
            url: 'https://hsgqgjkrbmkaxwhnktfv.supabase.co',
            anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhzZ3FnamtyYm1رYXh3aG5rdGZ2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTYyMTM1NDQsImV4cCI6MjA3MTc4OTU0NH0.WO3CQv-iHaxAin8pbS9h0CmDzfFC4Kb4sTaaYbBDM_Q',
          );
          return true;
        } catch (reconnectError) {
          print('❌ فشل إعادة الاتصال بـ Supabase: $reconnectError');
          return false;
        }
      }
    } catch (e) {
      print('❌ فشل في الاتصال بـ Supabase: $e');
      return false;
    }
  }

  Future<app_user.AppUser?> login(String code, String password) async {
    try {
      print('🔐 محاولة تسجيل الدخول بالكود: $code');

      final response = await supabase
          .from('users')
          .select()
          .eq('code', code)
          .eq('password', password)
          .timeout(const Duration(seconds: 15));

      if (response.isEmpty) {
        throw Exception('كود المستخدم أو كلمة المرور غير صحيحة');
      }

      final userData = response.first;
      print('✅ تم تسجيل الدخول بنجاح: ${userData['username']}');
      
      return app_user.AppUser.fromJson(userData);
    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      
      if (e is PostgrestException) {
        if (e.code == 'PGRST116') {
          throw Exception('بيانات الدخول غير صحيحة');
        }
        throw Exception('خطأ في الخادم: ${e.message}');
      } else if (e.toString().contains('SocketException') || e.toString().contains('TimeoutException')) {
        throw Exception('فشل في الاتصال بالإنترنت');
      } else {
        throw Exception('فشل في تسجيل الدخول: $e');
      }
    }
  }

  Future<List<Content>> getContent() async {
    try {
      print('📦 جلب المحتوى...');
      
      final response = await supabase
          .from('content')
          .select()
          .order('upload_date', ascending: false)
          .timeout(const Duration(seconds: 15));

      print('✅ تم جلب ${response.length} عنصر من المحتوى');
      return response.map((item) => Content.fromJson(item)).toList();
    } catch (e) {
      print('❌ خطأ في جلب المحتوى: $e');
      throw Exception('فشل في جلب المحتوى: $e');
    }
  }

  Future<List<Message>> getChatMessages() async {
    try {
      print('💬 جلب الرسائل...');
      
      final response = await supabase
          .from('messages')
          .select()
          .order('timestamp', ascending: true)
          .timeout(const Duration(seconds: 15));

      print('✅ تم جلب ${response.length} رسالة');
      
      final messagesWithUsers = <Message>[];
      
      for (var message in response) {
        try {
          final userResponse = await supabase
              .from('users')
              .select('username')
              .eq('code', message['sender_id'])
              .timeout(const Duration(seconds: 10));

          final username = userResponse.isNotEmpty ? userResponse[0]['username'] : 'مستخدم';
          
          messagesWithUsers.add(Message.fromJson({
            'id': message['id'].toString(),
            'content': message['content']?.toString() ?? '',
            'sender_id': message['sender_id']?.toString() ?? '',
            'username': username,
            'department': message['department']?.toString() ?? '',
            'division': message['division']?.toString() ?? '',
            'timestamp': message['timestamp']?.toString() ?? '',
          }));
        } catch (e) {
          print('❌ خطأ في جلب اسم المستخدم: $e');
          messagesWithUsers.add(Message.fromJson({
            'id': message['id'].toString(),
            'content': message['content']?.toString() ?? '',
            'sender_id': message['sender_id']?.toString() ?? '',
            'username': 'مستخدم',
            'department': message['department']?.toString() ?? '',
            'division': message['division']?.toString() ?? '',
            'timestamp': message['timestamp']?.toString() ?? '',
          }));
        }
      }
      
      return messagesWithUsers;
    } catch (e) {
      print('❌ خطأ في جلب الرسائل: $e');
      throw Exception('فشل في جلب الرسائل: $e');
    }
  }

  Future<bool> sendMessage({
    required String senderId,
    required String content,
  }) async {
    try {
      print('📤 إرسال رسالة...');
      
      final response = await supabase.from('messages').insert({
        'content': content,
        'sender_id': senderId,
        'department': '',
        'division': '',
        'timestamp': DateTime.now().toIso8601String(),
      }).select().timeout(const Duration(seconds: 15));

      if (response.isNotEmpty) {
        print('✅ تم إرسال الرسالة بنجاح');
        return true;
      }
      
      throw Exception('فشل في إرسال الرسالة');
    } catch (e) {
      print('❌ خطأ في إرسال الرسالة: $e');
      throw Exception('فشل في إرسال الرسالة: $e');
    }
  }

  Future<List<app_user.AppUser>> getUsers() async {
    try {
      print('👥 جلب المستخدمين...');
      
      final response = await supabase
          .from('users')
          .select()
          .order('username', ascending: true)
          .timeout(const Duration(seconds: 15));

      print('✅ تم جلب ${response.length} مستخدم');
      return response.map((item) => app_user.AppUser.fromJson(item)).toList();
    } catch (e) {
      print('❌ خطأ في جلب المستخدمين: $e');
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
      print('➕ إضافة مستخدم جديد: $username');
      
      final response = await supabase.from('users').insert({
        'code': code,
        'username': username,
        'department': '',
        'division': '',
        'role': role,
        'password': password,
      }).select().timeout(const Duration(seconds: 15));

      if (response.isNotEmpty) {
        print('✅ تم إضافة المستخدم بنجاح');
        return true;
      }
      
      throw Exception('فشل في إضافة المستخدم');
    } catch (e) {
      print('❌ خطأ في إضافة المستخدم: $e');
      throw Exception('فشل في إضافة المستخدم: $e');
    }
  }

  Future<bool> deleteUser(String code) async {
    try {
      print('🗑️ حذف المستخدم: $code');
      
      final response = await supabase
          .from('users')
          .delete()
          .eq('code', code)
          .select()
          .timeout(const Duration(seconds: 15));

      if (response.isNotEmpty) {
        print('✅ تم حذف المستخدم بنجاح');
        return true;
      }
      
      throw Exception('فشل في حذف المستخدم');
    } catch (e) {
      print('❌ خطأ في حذف المستخدم: $e');
      throw Exception('فشل في حذف المستخدم: $e');
    }
  }

  Future<bool> uploadContent({
    required String title,
    required String fileUrl,
    required String uploadedBy,
    required String description,
  }) async {
    try {
      print('📤 رفع محتوى: $title');
      
      if (!_isValidUrl(fileUrl)) {
        throw Exception('رابط الملف غير صحيح');
      }

      final userResponse = await supabase
          .from('users')
          .select('code')
          .eq('username', uploadedBy)
          .timeout(const Duration(seconds: 10));

      String uploadedByCode = userResponse.isNotEmpty ? userResponse[0]['code'] : uploadedBy;

      final response = await supabase.from('content').insert({
        'title': title,
        'file_path': fileUrl,
        'file_type': fileUrl.split('.').last.toLowerCase(),
        'file_size': '0',
        'uploaded_by': uploadedByCode,
        'department': '',
        'division': '',
        'description': description,
        'upload_date': DateTime.now().toIso8601String(),
      }).select().timeout(const Duration(seconds: 15));

      if (response.isNotEmpty) {
        print('✅ تم رفع المحتوى بنجاح');
        return true;
      }
      
      throw Exception('فشل في رفع المحتوى');
    } catch (e) {
      print('❌ خطأ في رفع المحتوى: $e');
      throw Exception('فشل في رفع المحتوى: $e');
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteContent(String id) async {
    try {
      print('🗑️ حذف المحتوى: $id');
      
      final response = await supabase
          .from('content')
          .delete()
          .eq('id', id)
          .select()
          .timeout(const Duration(seconds: 15));

      if (response.isNotEmpty) {
        print('✅ تم حذف المحتوى بنجاح');
        return true;
      }
      
      throw Exception('فشل في حذف المحتوى');
    } catch (e) {
      print('❌ خطأ في حذف المحتوى: $e');
      throw Exception('فشل في حذف المحتوى: $e');
    }
  }

  Future<bool> userExists(String code) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('code', code)
          .timeout(const Duration(seconds: 10));

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 10));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }
}

