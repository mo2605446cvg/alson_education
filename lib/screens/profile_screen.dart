import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:alson_education/models/user.dart';
import 'package:alson_education/widgets/app_bar_widget.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return FutureBuilder<User?>(
      future: DatabaseService().getUserByUsername(appState.currentUserEmail ?? ''),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError || snapshot.data == null) {
          return Scaffold(
            body: Center(
              child: Text('User not found or error: ${snapshot.error}'),
            ),
          );
        }

        final user = snapshot.data!;
        return Scaffold(
          appBar: CustomAppBar(AppStrings.get('profile', appState.language)),
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.class_),
                                const SizedBox(width: 10),
                                Text('${AppStrings.get('division', appState.language)}: ${user.division}'),
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
