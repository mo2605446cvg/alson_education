import 'package:flutter/material.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:alson_education/widgets/custom_appbar.dart';

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
  late StreamController<List<Map<String, dynamic>>> _messageStream;

  @override
  void initState() {
    super.initState();
    _messageStream = StreamController<List<Map<String, dynamic>>>.broadcast();
    _loadUsers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    currentUser = args ?? {'code': 'guest', 'username': 'Guest', 'department': 'غير محدد', 'role': 'user', 'password': ''};
  }

  Future<void> _loadUsers() async {
    final db = DatabaseService.instance;
    users = await db.query('users', where: 'code != ?', whereArgs: [currentUser['code']]);
    setState(() {});
    _startMessagePolling();
  }

  Future<void> _loadMessages() async {
    if (selectedReceiver != null) {
      final db = DatabaseService.instance;
      final fetchedMessages = await db.query(
        'chat',
        where: '(sender_code = ? AND receiver_code = ?) OR (sender_code = ? AND receiver_code = ?)',
        whereArgs: [currentUser['code'], selectedReceiver, selectedReceiver, currentUser['code']],
        orderBy: 'timestamp ASC',
      );
      _messageStream.add(fetchedMessages);
      setState(() => messages = fetchedMessages);
    }
  }

  void _startMessagePolling() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      if (mounted) await _loadMessages();
    });
  }

  Future<void> _sendMessage() async {
    if (selectedReceiver != null && _messageController.text.trim().isNotEmpty) {
      final db = DatabaseService.instance;
      await db.insert('chat', {
        'sender_code': currentUser['code'],
        'receiver_code': selectedReceiver!,
        'message': _messageController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
      await _loadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'الشات'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedReceiver,
              hint: Text('اختر المستخدم'),
              items: users.map((user) => DropdownMenuItem<String>(
                value: user['code'] as String,
                child: Text(user['username'] as String),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReceiver = value;
                  _loadMessages();
                });
              },
              isExpanded: true,
              borderRadius: BorderRadius.circular(15),
            ),
            SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _messageStream.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('لا توجد رسائل بعد'));
                  }
                  final messages = snapshot.data!;
                  return ListView.builder(
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
                            child: Text(
                              '${msg['message']} - ${DateFormat('HH:mm').format(DateTime.parse(msg['timestamp']))}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      labelText: 'اكتب رسالتك',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.send, color: AppColors.primaryColor),
                  onPressed: _sendMessage,
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/home', arguments: currentUser),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(minimumSize: Size(200, 50)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _messageStream.close();
    super.dispose();
  }
}
