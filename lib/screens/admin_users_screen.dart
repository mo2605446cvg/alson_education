import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/constants/strings.dart';

class AdminUsersScreen extends StatefulWidget {
  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  List<User> users = [];

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    final db = DatabaseService.instance;
    users = await db.getUsers();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('admin_users', appState.language))),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Text('${user.code} - ${user.department}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                await DatabaseService.instance.deleteUser(user.code);
                loadUsers();
              },
            ),
          );
        },
      ),
    );
  }
}