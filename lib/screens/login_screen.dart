import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:alson_education/constants/strings.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> validateLogin(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setLoading(true);

    final db = DatabaseService.instance;
    final user = await db.getUser(_usernameController.text.trim());
    if (user != null && user.password == _passwordController.text.trim()) {
      appState.login(user.username, user.code, user.role, user.department);
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid credentials')));
    }

    appState.setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('login', appState.language))),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/img/icon.png', width: 150),
            SizedBox(height: 20),
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: AppStrings.get('username', appState.language),
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: AppStrings.get('password', appState.language),
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: appState.isLoading ? null : () => validateLogin(context),
              child: Text(AppStrings.get('login', appState.language)),
              style: ElevatedButton.styleFrom(
                backgroundColor: PRIMARY_COLOR,
                foregroundColor: Colors.white,
                minimumSize: Size(200, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (appState.isLoading) CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
