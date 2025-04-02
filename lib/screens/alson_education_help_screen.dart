import 'package:flutter/material.dart';

class AlsonEducationHelpScreen extends StatelessWidget {
  const AlsonEducationHelpScreen({super.key});

  Widget _buildContactCard({
    required String subtitle,
    String title = 'اتصل بنا', // قيمة افتراضية
    IconData icon = Icons.help_outline, // إضافة أيقونة
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // إمكانية إضافة إجراء عند النقر
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مركز المساعدة'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildContactCard(
            title: 'الدعم الفني',
            subtitle: 'البريد الإلكتروني: support@alson.edu\nهاتف: 920000000',
            icon: Icons.support_agent,
          ),
          _buildContactCard(
            title: 'الشكاوى والمقترحات',
            subtitle: 'البريد الإلكتروني: feedback@alson.edu',
            icon: Icons.feedback,
          ),
          _buildContactCard(
            title: 'الأسئلة الشائعة',
            subtitle: 'تصفح قسم الأسئلة الشائعة في موقعنا الإلكتروني',
            icon: Icons.help_center,
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'ساعات العمل: من الأحد إلى الخميس، 8 صباحًا - 4 مساءً',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
