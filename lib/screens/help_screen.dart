import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _bodyController = TextEditingController();
  bool _isSending = false;

  Future<void> _launchURL(String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        _showError('تعذر فتح الرابط');
      }
    } catch (e) {
      _showError('حدث خطأ: ${e.toString()}');
    }
  }

  Future<void> _sendEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);

    try {
      final Email email = Email(
        body: _bodyController.text,
        subject: _subjectController.text,
        recipients: ['m.nasrmm2002@gmail.com'],
        isHTML: false,
      );

      await FlutterEmailSender.send(email);
      _showSuccess('تم إرسال البريد بنجاح');
      _subjectController.clear();
      _bodyController.clear();
    } catch (e) {
      _showError('فشل إرسال البريد: ${e.toString()}');
    } finally {
      setState(() => _isSending = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('مركز المساعدة'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تواصل معنا',
              style: Theme.of(context).textTheme.headline5?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            SizedBox(height: 20),
            _buildContactCard(
              icon: Icons.email,
              title: 'البريد الإلكتروني',
              subtitle: 'm.nasrmm2002@gmail.com',
              onTap: () => _launchURL('mailto:m.nasrmm2002@gmail.com'),
            ),
            _buildContactCard(
              icon: Icons.phone,
              title: 'الهاتف',
              subtitle: '+201023828155',
              onTap: () => _launchURL('tel:+201023828155'),
            ),
            _buildContactCard(
              icon: Icons.access_time,
              title: 'ساعات العمل',
              subtitle: '9//5',
              onTap: null,
            ),
            Divider(height: 40),
            Text(
              'إرسال استفسار',
              style: Theme.of(context).textTheme.headline5?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            SizedBox(height: 15),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _subjectController,
                    decoration: InputDecoration(
                      labelText: 'الموضوع',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال الموضوع' : null,
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _bodyController,
                    decoration: InputDecoration(
                      labelText: 'الاستفسار',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 5,
                    validator: (value) =>
                        value!.isEmpty ? 'يرجى إدخال الاستفسار' : null,
                  ),
                  SizedBox(height: 20),
                  _isSending
                      ? CircularProgressIndicator()
                      : ElevatedButton.icon(
                          icon: Icon(Icons.send),
                          label: Text('إرسال الاستفسار'),
                          onPressed: _sendEmail,
                          style: ElevatedButton.styleFrom(
                            minimumSize: Size(double.infinity, 50),
                          ),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 15),
      child: ListTile(
        leading: Icon(icon, size: 30),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
        trailing: onTap != null ? Icon(Icons.chevron_left) : null,
      ),
    );
  }
}