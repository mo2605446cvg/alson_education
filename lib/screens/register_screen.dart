import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/colors.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:alson_education/models/user.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _codeController = TextEditingController();
  final _departmentController = TextEditingController();
  final _divisionController = TextEditingController();

  Future<void> _register(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.setLoading(true);

    try {
      if (_usernameController.text.isEmpty ||
          _codeController.text.isEmpty ||
          _departmentController.text.isEmpty ||
          _divisionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
        return;
      }

      final user = User(
        code: _codeController.text.trim(),
        username: _usernameController.text.trim(),
        department: _departmentController.text.trim(),
        division: _divisionController.text.trim(),
        role: 'user',
        password: _codeController.text.trim(),
      );

      await DatabaseService().insertUser(user);
      appState.login(user.username, user.code, user.role, user.department, division: user.division);
      Navigator.pushReplacementNamed(context, '/home');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registration successful')));
    } catch (e) {
      appState.setError('Registration failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    } finally {
      appState.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('register', appState.language)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('username', appState.language),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('code', appState.language),
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('department', appState.language),
                  prefixIcon: const Icon(Icons.group),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _divisionController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('division', appState.language),
                  prefixIcon: const Icon(Icons.class_),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: appState.isLoading ? null : () => _register(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: PRIMARY_COLOR,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: appState.isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(AppStrings.get('register', appState.language)),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: Text(AppStrings.get('login', appState.language)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
