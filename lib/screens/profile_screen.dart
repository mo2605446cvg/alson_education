import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state.dart';
import 'package:alson_education/services/database.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    if (state.currentUser['code'] == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تسجيل الدخول أولاً', style: TextStyle(color: Colors.red))));
      });
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchUserProfile(state.currentUser['code'], context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.blue));
        }

        if (snapshot.hasError) {
          ErrorHandler.handleError(snapshot.error, 'Failed to fetch profile');
          return const Center(child: Text('حدث خطأ أثناء جلب الملف الشخصي'));
        }

        final user = snapshot.data;
        if (user == null) {
          Navigator.pushReplacementNamed(context, '/');
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('المستخدم غير موجود', style: TextStyle(color: Colors.red))));
          return const SizedBox.shrink();
        }

        return Scaffold(
          key: ErrorHandler.navigatorKey,
          appBar: AppBar(
            title: const Text('الملف الشخصي', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.blue,
            elevation: 10,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'الملف الشخصي',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    width: 340,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.person, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('الاسم: ${user['username']}', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.lock, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('الكود: ${user['code']}', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        ]),
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.group, color: Colors.blue),
                          const SizedBox(width: 10),
                          Text('القسم: ${user['department']}', style: const TextStyle(fontSize: 16, color: Colors.black87)),
                        ]),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('عودة'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchUserProfile(String? code, BuildContext context) async {
    if (code == null) return null;

    try {
      final db = DatabaseService.instance;
      final users = await db.query('users', where: 'code = ?', whereArgs: [code]);
      return users.isNotEmpty ? users[0] : null;
    } catch (e) {
      ErrorHandler.handleError(e, 'Failed to fetch user profile');
      return null;
    }
  }
}