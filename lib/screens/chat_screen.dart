import 'package:flutter/material.dart';
import 'package:alson_education/database/database_helper.dart';
import 'package:alson_education/models/user.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  List<User> _users = [];
  String? _selectedUserId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    final users = await db.query('users');
    setState(() {
      _users = users.map((user) => User.fromMap(user)).toList();
      _isLoading = false;
    });
  }

  Future<void> _loadMessages() async {
    if (_selectedUserId == null) return;

    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    final messages = await db.query(
      'chat',
      where: '(sender_code = ? AND receiver_code = ?) OR (sender_code = ? AND receiver_code = ?)',
      whereArgs: ['admin123', _selectedUserId, _selectedUserId, 'admin123'],
      orderBy: 'timestamp',
    );

    setState(() {
      _messages = messages;
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty || _selectedUserId == null) return;

    final db = await DatabaseHelper.instance.database;
    await db.insert('chat', {
      'sender_code': 'admin123',
      'receiver_code': _selectedUserId,
      'message': _messageController.text,
      'timestamp': DateTime.now().toString(),
    });

    _messageController.clear();
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('الشات')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: _selectedUserId,
            hint: Text('اختر مستخدماً'),
            items: _users.map((user) {
              return DropdownMenuItem(
                value: user.code,
                child: Text(user.username),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedUserId = value);
              _loadMessages();
            },
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isMe = message['sender_code'] == 'admin123';
                      
                      return Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.blue[100] : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(message['message']),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالة...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}