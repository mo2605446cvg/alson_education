import 'package:flutter/material.dart';
import 'package:alson_education/screens/database.dart'; // تأكد من تعديل المسار إلى services/database.dart إذا لزم الأمر
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  String? _selectedUserCode;
  List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final db = DatabaseService();
    final users = await db.getUsersExceptCurrent(user['code']);
    setState(() {
      _selectedUserCode = users.isNotEmpty ? users[0]['code'] : null;
      _loadMessages(user['code']);
    });
  }

  Future<void> _loadMessages(String currentUserCode) async {
    if (_selectedUserCode != null) {
      final db = DatabaseService();
      final messages = await db.getChatMessages(currentUserCode, _selectedUserCode!);
      setState(() => _messages = messages);
    }
  }

  Future<void> _sendMessage(String currentUserCode) async {
    if (_messageController.text.isNotEmpty && _selectedUserCode != null) {
      final db = DatabaseService();
      await db.sendMessage(currentUserCode, _selectedUserCode!, _messageController.text);
      _messageController.clear();
      _loadMessages(currentUserCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الشات', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: DatabaseService().getUsersExceptCurrent(user['code']),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return DropdownButton<String>(
                  value: _selectedUserCode,
                  items: snapshot.data!.map<DropdownMenuItem<String>>((u) => DropdownMenuItem<String>(
                        value: u['code'].toString(), // تحويل القيمة إلى String صراحةً
                        child: Text(u['username'].toString()), // تحويل اسم المستخدم إلى String أيضًا
                      )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedUserCode = value;
                      _loadMessages(user['code']);
                    });
                  },
                  hint: const Text('اختر المستخدم'),
                  isExpanded: true,
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isMe = msg['sender_code'] == user['code'];
                  final formattedTime = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(msg['timestamp']));
                  return Align(
                    alignment: isMe ? Alignment.topRight : Alignment.topLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isMe ? Colors.grey[100] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('${msg['message']} - $formattedTime'),
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
                    decoration: const InputDecoration(labelText: 'اكتب رسالتك', border: OutlineInputBorder()),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () => _sendMessage(user['code']),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800], foregroundColor: Colors.white),
              child: const Text('عودة'),
            ),
          ],
        ),
      ),
    );
  }
}