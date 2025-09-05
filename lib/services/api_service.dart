import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/models/content.dart';
import 'package:alson_education/models/message.dart';

class ApiService {
  final SupabaseClient supabase = Supabase.instance.client;

  // دالة للتحقق من اتصال Supabase
  Future<bool> checkSupabaseConnection() async {
    try {
      // استخدام الطريقة الصحيحة للتحقق من الاتصال في الإصدارات الحديثة
      final session = supabase.auth.currentSession;
      return session != null;
    } catch (e) {
      print('❌ فشل في الاتصال بـ Supabase: $e');
      return false;
    }
  }

  // تسجيل الدخول - الإصدار المصحح
  Future<app_user.AppUser?> login(String code, String password) async {
    try {
      print('🔐 محاولة تسجيل الدخول بالكود: $code');

      // استخدام query صحيحة لـ Supabase
      final response = await supabase
          .from('users')
          .select()
          .eq('code', code)
          .eq('password', password);

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
      } else if (e.toString().contains('SocketException')) {
        throw Exception('فشل في الاتصال بالإنترنت');
      } else {
        throw Exception('فشل في تسجيل الدخول: $e');
      }
    }
  }

  // جلب المحتوى - الإصدار المصحح
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

  // جلب الرسائل - الإصدار المصحح
  Future<List<Message>> getChatMessages() async {
    try {
      print('💬 جلب الرسائل...');
      
      final response = await supabase
          .from('messages')
          .select()
          .order('timestamp', ascending: true);

      print('✅ تم جلب ${response.length} رسالة');
      
      final messagesWithUsers = <Message>[];
      
      for (var message in response) {
        try {
          // الحصول على اسم المستخدم
          final userResponse = await supabase
              .from('users')
              .select('username')
              .eq('code', message['sender_id']);

          final username = userResponse.isNotEmpty ? userResponse[0]['username'] : 'مستخدم';
          
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

  // إرسال رسالة - الإصدار المصحح
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
      }).select();

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

  // جلب المستخدمين - الإصدار المصحح
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

  // إضافة مستخدم - الإصدار المصحح
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
      }).select();

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

  // حذف مستخدم - الإصدار المصحح
  Future<bool> deleteUser(String code) async {
    try {
      print('🗑️ حذف المستخدم: $code');
      
      final response = await supabase
          .from('users')
          .delete()
          .eq('code', code)
          .select();

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

  // رفع محتوى - الإصدار المصحح
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

      // البحث عن كود المستخدم
      final userResponse = await supabase
          .from('users')
          .select('code')
          .eq('username', uploadedBy);

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
      }).select();

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

  // التحقق من صحة الرابط
  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  // حذف محتوى - الإصدار المصحح
  Future<bool> deleteContent(String id) async {
    try {
      print('🗑️ حذف المحتوى: $id');
      
      final response = await supabase
          .from('content')
          .delete()
          .eq('id', id)
          .select();

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

  // دالة مساعدة للتحقق من وجود المستخدم
  Future<bool> userExists(String code) async {
    try {
      final response = await supabase
          .from('users')
          .select()
          .eq('code', code);

      return response.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
