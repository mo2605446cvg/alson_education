import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/constants/strings.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final List<String> messages = [];

  void _addMessage(String message) {
    setState(() {
      messages.add(message);
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('chat', appState.language)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(child: Text(AppStrings.get('no_messages', appState.language) ?? 'No messages yet'))
                : ListView.builder(
                    padding: const EdgeInsets.all(20.0),
                    itemCount: messages.length,
                    itemBuilder: (context, index) => ListTile(
                      title: Text(messages[index], textAlign: TextAlign.center),
                    ),
                  ),
          ),
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
                      errorText: _messageController.text.isEmpty ? 'Message cannot be empty' : null,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _messageController.text.isEmpty
                      ? null
                      : () => _addMessage(_messageController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
