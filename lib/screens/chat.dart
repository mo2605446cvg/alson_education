
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
  }

  Future<void> _fetchMessages() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      final data = await getChatMessages(user.department, user.division);
      setState(() => _messages = data);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في جلب الرسائل')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال نص الرسالة')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      await sendMessage(user.code, user.department, user.division, _messageController.text);
      _messageController.clear();
      _fetchMessages();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إرسال الرسالة')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBarWidget(isAdmin: user.role == 'admin'),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Text(
                'الشات',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Cairo',
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _messages.isEmpty
                    ? const Center(child: Text('لا توجد رسائل', style: TextStyle(color: textColor, fontFamily: 'Cairo')))
                    : ListView.builder(
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(message.username, style: const TextStyle(fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                                Text(message.content, style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                                Text(
                                  DateFormat('yyyy-MM-dd HH:mm', 'ar').format(DateTime.parse(message.timestamp)),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (user.role == 'admin') ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        enabled: !_isLoading,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: primaryColor),
                      onPressed: _isLoading ? null : _handleSendMessage,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}