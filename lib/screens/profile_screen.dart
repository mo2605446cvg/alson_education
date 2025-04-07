import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:alson_education/constants/strings.dart';
import 'package:alson_education/models/user.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          return const Scaffold(body: Center(child: Text('User not found')));
        }

        final user = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(AppStrings.get('profile', appState.language)),
            centerTitle: true,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.get('profile', appState.language),
                      style: Theme.of(context).textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.person),
                                const SizedBox(width: 10),
                                Text('${AppStrings.get('name', appState.language)}: ${user.username}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.lock),
                                const SizedBox(width: 10),
                                Text('${AppStrings.get('code', appState.language)}: ${user.code}'),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.group),
                                const SizedBox(width: 10),
                                Text('${AppStrings.get('department', appState.language)}: ${user.department}'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PRIMARY_COLOR,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(AppStrings.get('back', appState.language)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
