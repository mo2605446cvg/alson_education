import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:alson_education/models/user.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> validateLogin(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setLoading(true);

    try {
      final db = DatabaseService.instance;
      final user = await db.getUser(_usernameController.text.trim());

      if (user != null && user.password == _passwordController.text.trim()) {
        appState.login(user.username, user.code, user.role, user.department);
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login successful')));
      } else {
        appState.setError('Invalid username or password');
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid username or password')));
      }
    } catch (e) {
      appState.setError('Login failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed: $e')));
    } finally {
      appState.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('login', appState.language)),
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
                Image.asset('assets/img/icon.png', width: 150),
                const SizedBox(height: 20),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('username', appState.language),
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    errorText: appState.hasError ? appState.errorMessage : null,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('password', appState.language),
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    errorText: appState.hasError ? appState.errorMessage : null,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: appState.isLoading ? null : () => validateLogin(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: PRIMARY_COLOR,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(200, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: appState.isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(AppStrings.get('login', appState.language)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
