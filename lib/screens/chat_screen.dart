import 'package:flutter/material.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Map<String, dynamic> currentUser;
  String? selectedReceiver;
  final _messageController = TextEditingController();
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> users = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentUser = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = DatabaseService.instance;
    users = await db.query('users', where: 'code != ?', whereArgs: [currentUser['code']]);
    setState(() {});
  }

  Future<void> _loadMessages() async {
    if (selectedReceiver != null) {
      final db = DatabaseService.instance;
      messages = await db.query('chat', where: '(sender_code = ? AND receiver_code = ?) OR (sender_code = ? AND receiver_code = ?)',
          whereArgs: [currentUser['code'], selectedReceiver, selectedReceiver, currentUser['code']], orderBy: 'timestamp');
      setState(() {});
    }
  }

  void _sendMessage() async {
    if (selectedReceiver != null && _messageController.text.isNotEmpty) {
      final db = DatabaseService.instance;
      await db.insert('chat', {
        'sender_code': currentUser['code'],
        'receiver_code': selectedReceiver!,
        'message': _messageController.text,
        'timestamp': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
      _loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الشات', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedReceiver,
              hint: Text('اختر المستخدم'),
              items: users.map((user) => DropdownMenuItem(value: user['code'], child: Text(user['username']))).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReceiver = value;
                  _loadMessages();
                });
              },
              isExpanded: true,
              borderRadius: BorderRadius.circular(15),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isSentByMe = msg['sender_code'] == currentUser['code'];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    child: Align(
                      alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSentByMe ? Colors.grey[200] : Colors.blue[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${msg['message']} - ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(msg['timestamp']))}',
                            style: TextStyle(color: isSentByMe ? AppColors.textColor : Colors.blue)),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(labelText: 'اكتب رسالتك', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                ),
                IconButton(icon: Icon(Icons.send, color: AppColors.primaryColor), onPressed: _sendMessage),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home', arguments: currentUser),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(primary: AppColors.primaryColor, minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }
}
