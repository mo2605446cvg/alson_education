import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/constants/colors.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _receiverController = TextEditingController();
  final _messageController = TextEditingController();
  List<Map> messages = [];

  Future<void> loadChat(String receiverCode) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final db = await DatabaseService.instance.database;
    messages = await db.rawQuery('''
      SELECT * FROM chat WHERE (sender_code = ? AND receiver_code = ?) OR (sender_code = ? AND receiver_code = ?) ORDER BY timestamp
    ''', [appState.currentUserCode, receiverCode, receiverCode, appState.currentUserCode]);
    setState(() {});
  }

  Future<void> sendMessage() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (_receiverController.text.isNotEmpty && _messageController.text.isNotEmpty) {
      final db = await DatabaseService.instance.database;
      await db.rawInsert('''
        INSERT INTO chat (sender_code, receiver_code, message, timestamp) VALUES (?, ?, ?, ?)
      ''', [appState.currentUserCode, _receiverController.text, _messageController.text, DateTime.now().toIso8601String()]);
      _messageController.clear();
      loadChat(_receiverController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text('الشات')),
      body: Container(
        padding: EdgeInsets.all(20),
        color: SECONDARY_COLOR,
        child: Column(
          children: [
            TextField(
              controller: _receiverController,
              decoration: InputDecoration(labelText: 'اختر المستخدم', border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              onChanged: (value) => loadChat(value),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  final isSent = message['sender_code'] == appState.currentUserCode;
                  return Align(
                    alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSent ? Colors.grey[300] : Colors.blue[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(message['message']),
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
                IconButton(icon: Icon(Icons.send), onPressed: sendMessage),
              ],
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('عودة'),
              style: ElevatedButton.styleFrom(backgroundColor: PRIMARY_COLOR, foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}