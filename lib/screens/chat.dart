import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/models/message.dart';
import 'dart:async';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}


class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  List<Message> _messages = [];
  bool _isLoading = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    FirebaseMessaging.instance.subscribeToTopic('all_users');
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message.notification?.body ?? 'رسالة جديدة')),
      );
      _fetchMessages();
    });
    _fetchMessages();
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) _fetchMessages();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchMessages() async {
  setState(() => _isLoading = true);
  try {
    final data = await getMessages();
    setState(() => _messages = data);
  } catch (error) {
    print('Error in _fetchMessages: $error');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل في جلب الرسائل: $error')),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}


  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال رسالة')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      await sendMessage(user.code, _messageController.text);
      _messageController.clear();
      await _fetchMessages();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال الرسالة بنجاح')),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في إرسال الرسالة: تأكد من الاتصال بالإنترنت')),
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
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'الشات',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                  fontFamily: 'Cairo',
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: _fetchMessages,
                child: const Text('تحديث الرسائل', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? const Center(child: Text('لا توجد رسائل', style: TextStyle(color: textColor, fontFamily: 'Cairo')))
                      : ListView.builder(
                          reverse: true,
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[_messages.length - 1 - index];
                            final isMe = message.senderId == user.code;
                            return Align(
                              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isMe ? primaryColor : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
                                ),
                                child: Column(
                                  crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.username,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isMe ? Colors.white : textColor,
                                        fontFamily: 'Cairo',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isMe ? Colors.white : textColor,
                                        fontFamily: 'Cairo',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      message.timestamp,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isMe ? Colors.white70 : Colors.grey,
                                        fontFamily: 'Cairo',
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالتك...',
                        hintStyle: TextStyle(fontFamily: 'Cairo'),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: primaryColor),
                    onPressed: _isLoading ? null : _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}