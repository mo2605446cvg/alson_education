import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/widgets/app_bar_widget.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  late Future<List<User>> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = DatabaseService().getUsers();
  }

  Future<void> _updateUser(User user) async {
    final updatedUser = User(
      code: user.code,
      username: user.username,
      department: user.department,
      division: user.division,
      role: user.role,
      password: user.password,
    );
    try {
      await DatabaseService().updateUser(updatedUser);
      setState(() {
        _usersFuture = DatabaseService().getUsers();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User updated')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    }
  }

  Future<void> _deleteUser(String code) async {
    try {
      await DatabaseService().deleteUser(code);
      setState(() {
        _usersFuture = DatabaseService().getUsers();
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User deleted')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: CustomAppBar(AppStrings.get('admin_users', appState.language), isAdmin: appState.isAdmin),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading users: ${snapshot.error}'));
          }
          final users = snapshot.data ?? [];
          return ListView.builder(
            padding: const EdgeInsets.all(20.0),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.username),
                subtitle: Text('Code: ${user.code}, Dept: ${user.department}, Div: ${user.division}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _updateUser(user),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteUser(user.code),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
