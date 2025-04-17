import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/models/message.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:alson_education/widgets/app_bar_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  Future<void> _sendMessage(BuildContext context) async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (_messageController.text.isEmpty || !appState.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only admins can send messages')));
      return;
    }

    final message = Message(
      id: DateTime.now().toString(),
      content: _messageController.text,
      senderId: appState.currentUserCode!,
      department: appState.currentUserDepartment!,
      division: appState.currentUserDivision!,
      timestamp: DateTime.now().toString(),
    );

    try {
      await DatabaseService().insertMessage(message);
      _messageController.clear();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to send message: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: CustomAppBar(AppStrings.get('chat', appState.language), isAdmin: appState.isAdmin),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: DatabaseService().getMessages(
                appState.currentUserDepartment ?? '',
                appState.currentUserDivision ?? '',
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final messages = snapshot.data ?? [];
                return messages.isEmpty
                    ? Center(child: Text(AppStrings.get('no_messages', appState.language)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(20.0),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          return ListTile(
                            title: Text(message.content, textAlign: TextAlign.center),
                            subtitle: Text(
                              '${message.timestamp} by ${message.senderId}',
                              textAlign: TextAlign.center,
                            ),
                          );
                        },
                      );
              },
            ),
          ),
          if (appState.isAdmin)
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('message', appState.language),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _sendMessage(context),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
