import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:alson_education/constants/strings.dart';

class ProfileScreen extends StatelessWidget {
  Future<User?> getUserData(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    return await DatabaseService.instance.getUser(appState.currentUserCode ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return FutureBuilder<User?>(
      future: getUserData(context),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(body: Center(child: Text('User not found')));
        }

        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(title: Text(AppStrings.get('profile', appState.language))),
          body: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Text(AppStrings.get('profile', appState.language), style: Theme.of(context).textTheme.headlineSmall),
                SizedBox(height: 20),
                Card(
                  elevation: 5,
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Column(
                      children: [
                        Row(children: [Icon(Icons.person), Text('${AppStrings.get('name', appState.language)}: ${user.username}')]),
                        Row(children: [Icon(Icons.lock), Text('${AppStrings.get('code', appState.language)}: ${user.code}')]),
                        Row(children: [Icon(Icons.group), Text('${AppStrings.get('department', appState.language)}: ${user.department}')]),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppStrings.get('back', appState.language)),
                  style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR, foregroundColor: Colors.white),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
