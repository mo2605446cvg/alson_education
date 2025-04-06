import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/colors.dart';

class ProfileScreen extends StatelessWidget {
  Future<Map?> getUserData(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.currentUserCode == null) return null;

    final db = await DatabaseService.instance.database;
    final result = await db.rawQuery("SELECT * FROM users WHERE code=?", [appState.currentUserCode]);
    return result.isNotEmpty ? result.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map?>(
      future: getUserData(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(body: Center(child: Text('المستخدم غير موجود')));
        }

        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text('الملف الشخصي')),
          body: Container(
            padding: EdgeInsets.all(20),
            color: SECONDARY_COLOR,
            child: Column(
              children: [
                Text('الملف الشخصي', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: PRIMARY_COLOR)),
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    padding: EdgeInsets.all(15),
                    width: 340,
                    child: Column(
                      children: [
                        Row(children: [Icon(Icons.person, color: PRIMARY_COLOR), Text('الاسم: ${user['username']}')]),
                        Row(children: [Icon(Icons.lock, color: PRIMARY_COLOR), Text('الكود: ${user['code']}')]),
                        Row(children: [Icon(Icons.group, color: PRIMARY_COLOR), Text('القسم: ${user['department']}')]),
                      ],
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('عودة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                    foregroundColor: Colors.white,
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
