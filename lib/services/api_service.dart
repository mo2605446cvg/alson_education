import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';

class ApiService {
  final SupabaseClient supabase = Supabase.instance.client;

  // دالة للتحقق من اتصال Supabase
  Future<bool> checkSupabaseConnection() async {
    try {
      final result = await supabase.from('users').select('count').limit(1);
      return result != null;
    } catch (e) {
      print('❌ فشل في الاتصال بـ Supabase: $e');
      return false;
    }
  }

  // تسجيل الدخول - الإصدار المعدل
  Future<app_user.AppUser?> login(String code, String password) async {
    try {
      print('🔐 محاولة تسجيل الدخول بالكود: $code');

      // البحث عن المستخدم بالكود فقط أولاً
      final userResponse = await supabase
          .from('users')
          .select()
          .eq('code', code)
          .maybeSingle();

      if (userResponse == null) {
        throw Exception('كود المستخدم غير صحيح');
      }

      // التحقق من كلمة المرور
      if (userResponse['password'] != password) {
        throw Exception('كلمة المرور غير صحيحة');
      }

      print('✅ تم تسجيل الدخول بنجاح: ${userResponse['username']}');
      return app_user.AppUser.fromJson(userResponse);

    } catch (e) {
      print('❌ خطأ في تسجيل الدخول: $e');
      if (e is PostgrestException) {
        throw Exception('خطأ في قاعدة البيانات: ${e.message}');
      } else {
        rethrow;
      }
    }
  }

  // جلب المحتوى
  Future<List<Content>> getContent() async {
    try {
      print('📦 جلب المحتوى...');
      
      final response = await supabase
          .from('content')
          .select()
          .order('upload_date', ascending: false);

      print('✅ تم جلب ${response.length} عنصر من المحتوى');
      return response.map((item) => Content.fromJson(item)).toList();

    } catch (e) {
      print('❌ خطأ في جلب المحتوى: $e');
      throw Exception('فشل في جلب المحتوى: $e');
    }
  }

  // جلب الرسائل
  Future<List<Message>> getChatMessages() async {
    try {
      print('💬 جلب الرسائل...');
      
      final response = await supabase
          .from('messages')
          .select()
          .order('timestamp', ascending: true);

      print('✅ تم جلب ${response.length} رسالة');
      
      // محاولة الحصول على أسماء المستخدمين بشكل منفصل إذا فشل الjoin
      final messagesWithUsers = <Message>[];
      
      for (var message in response) {
        try {
          // الحصول على اسم المستخدم من جدول users
          final userResponse = await supabase
              .from('users')
              .select('username')
              .eq('code', message['sender_id'])
              .maybeSingle();

          final username = userResponse?['username'] ?? 'مستخدم';
          
          messagesWithUsers.add(Message.fromJson({
            'id': message['id'],
            'content': message['content'],
            'sender_id': message['sender_id'],
            'username': username,
            'department': message['department'] ?? '',
            'division': message['division'] ?? '',
            'timestamp': message['timestamp'],
          }));
        } catch (e) {
          // إذا فشل الحصول على اسم المستخدم
          messagesWithUsers.add(Message.fromJson({
            'id': message['id'],
            'content': message['content'],
            'sender_id': message['sender_id'],
            'username': 'مستخدم',
            'department': message['department'] ?? '',
            'division': message['division'] ?? '',
            'timestamp': message['timestamp'],
          }));
        }
      }
      
      return messagesWithUsers;

    } catch (e) {
      print('❌ خطأ في جلب الرسائل: $e');
      throw Exception('فشل في جلب الرسائل: $e');
    }
  }

  // إرسال رسالة
  Future<bool> sendMessage({
    required String senderId,
    required String content,
  }) async {
    try {
      print('📤 إرسال رسالة...');
      
      await supabase.from('messages').insert({
        'content': content,
        'sender_id': senderId,
        'department': '',
        'division': '',
        'timestamp': DateTime.now().toIso8601String(),
      });

      print('✅ تم إرسال الرسالة بنجاح');
      return true;

    } catch (e) {
      print('❌ خطأ في إرسال الرسالة: $e');
      throw Exception('فشل في إرسال الرسالة: $e');
    }
  }

  // جلب المستخدمين
  Future<List<app_user.AppUser>> getUsers() async {
    try {
      print('👥 جلب المستخدمين...');
      
      final response = await supabase
          .from('users')
          .select()
          .order('username', ascending: true);

      print('✅ تم جلب ${response.length} مستخدم');
      return response.map((item) => app_user.AppUser.fromJson(item)).toList();

    } catch (e) {
      print('❌ خطأ في جلب المستخدمين: $e');
      throw Exception('فشل في جلب المستخدمين: $e');
    }
  }

  // إضافة مستخدم
  Future<bool> addUser({
    required String code,
    required String username,
    required String role,
    required String password,
  }) async {
    try {
      print('➕ إضافة مستخدم جديد: $username');
      
      await supabase.from('users').insert({
        'code': code,
        'username': username,
        'department': '',
        'division': '',
        'role': role,
        'password': password,
      });

      print('✅ تم إضافة المستخدم بنجاح');
      return true;

    } catch (e) {
      print('❌ خطأ في إضافة المستخدم: $e');
      throw Exception('فشل في إضافة المستخدم: $e');
    }
  }

  // حذف مستخدم
  Future<bool> deleteUser(String code) async {
    try {
      print('🗑️ حذف المستخدم: $code');
      
      await supabase
          .from('users')
          .delete()
          .eq('code', code);

      print('✅ تم حذف المستخدم بنجاح');
      return true;

    } catch (e) {
      print('❌ خطأ في حذف المستخدم: $e');
      throw Exception('فشل في حذف المستخدم: $e');
    }
  }

  // رفع محتوى - الإصدار المحسن
  Future<bool> uploadContent({
    required String title,
    required String fileUrl,
    required String uploadedBy,
    required String description,
  }) async {
    try {
      print('📤 رفع محتوى: $title');
      
      // التحقق من صحة الرابط
      if (!_isValidUrl(fileUrl)) {
        throw Exception('رابط الملف غير صحيح');
      }

      // البحث عن المستخدم بالاسم للحصول على الكود
      final userResponse = await supabase
          .from('users')
          .select('code')
          .eq('username', uploadedBy)
          .maybeSingle();

      String uploadedByCode = userResponse?['code'] ?? uploadedBy;

      // إدخال البيانات مع معالجة الأخطاء
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
      }).select();

      if (response != null && response.isNotEmpty) {
        print('✅ تم رفع المحتوى بنجاح');
        return true;
      } else {
        throw Exception('فشل في إضافة المحتوى إلى قاعدة البيانات');
      }

    } catch (e) {
      print('❌ خطأ في رفع المحتوى: $e');
      
      // معالجة أخطاء محددة
      if (e is PostgrestException) {
        if (e.code == '23503') {
          throw Exception('المستخدم غير موجود في النظام. يرجى استخدام اسم مستخدم صحيح');
        } else if (e.code == '23505') {
          throw Exception('هذا المحتوى موجود مسبقاً');
        } else {
          throw Exception('خطأ في قاعدة البيانات: ${e.message}');
        }
      }
      
      throw Exception('فشل في رفع المحتوى: ${e.toString()}');
    }
  }

  // التحقق من صحة الرابط
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // حذف محتوى
  Future<bool> deleteContent(String id) async {
    try {
      print('🗑️ حذف المحتوى: $id');
      
      await supabase
          .from('content')
          .delete()
          .eq('id', id);

      print('✅ تم حذف المحتوى بنجاح');
      return true;

    } catch (e) {
      print('❌ خطأ في حذف المحتوى: $e');
      throw Exception('فشل في حذف المحتوى: $e');
    }
  }
}