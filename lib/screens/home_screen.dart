
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBarWidget(isAdmin: user.role == 'admin'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('مرحبًا، ${user.name}', style: const TextStyle(fontFamily: 'Cairo', fontSize: 24)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/content'),
                child: const Text('عرض المحتوى', style: TextStyle(fontFamily: 'Cairo')),
              ),
              const SizedBox(height: 16),
              if (user.role == 'admin') ...[
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/upload'),
                  child: const Text('رفع محتوى', style: TextStyle(fontFamily: 'Cairo')),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/users'),
                  child: const Text('إدارة المستخدمين', style: TextStyle(fontFamily: 'Cairo')),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/chat'),
                child: const Text('الدردشة', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}