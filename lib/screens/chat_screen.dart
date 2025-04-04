import 'package:flutter/material.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:alson_education/screens/home_screen.dart';
import 'package:intl/intl.dart';
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
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      _handleError('لا توجد بيانات مستخدم');
      return;
    }
    currentUser = args;
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    final db = DatabaseService.instance;
    try {
      users = await db.query('users', where: 'code != ?', whereArgs: [currentUser['code']]);
      setState(() {
        _isLoading = false;
      });
      if (selectedReceiver != null) {
        _loadMessages();
      }
    } catch (e) {
      _handleError('فشل في تحميل المستخدمين: $e');
    }
  }

  Future<void> _loadMessages() async {
    if (selectedReceiver == null) return;
    final db = DatabaseService.instance;
    try {
      messages = await db.query(
        'chat',
        where: '(sender_code = ? AND receiver_code = ?) OR (sender_code = ? AND receiver_code = ?)',
        whereArgs: [currentUser['code'], selectedReceiver, selectedReceiver, currentUser['code']],
        orderBy: 'timestamp ASC',
      );
      setState(() {});
    } catch (e) {
      _handleError('فشل في تحميل الرسائل: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (selectedReceiver == null || _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى اختيار مستلم وكتابة رسالة', style: TextStyle(color: AppColors.errorColor))),
      );
      return;
    }

    final db = DatabaseService.instance;
    try {
      await db.insert('chat', {
        'sender_code': currentUser['code'],
        'receiver_code': selectedReceiver!,
        'message': _messageController.text.trim(),
        'timestamp': DateTime.now().toIso8601String(),
      });
      _messageController.clear();
      await _loadMessages();
    } catch (e) {
      _handleError('فشل في إرسال الرسالة: $e');
    }
  }

  void _handleError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: AppColors.errorColor))),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.secondaryColor,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(title: 'الشات'),
      backgroundColor: AppColors.secondaryColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedReceiver,
              hint: Text('اختر المستخدم', style: TextStyle(color: AppColors.textColor)),
              items: users.map((user) => DropdownMenuItem<String>(
                value: user['code'] as String,
                child: Text(user['username'] as String, style: TextStyle(color: AppColors.textColor)),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  selectedReceiver = value;
                  _loadMessages();
                });
              },
              isExpanded: true,
              borderRadius: BorderRadius.circular(15),
              dropdownColor: Colors.white,
            ),
            SizedBox(height: 10),
            Expanded(
              child: messages.isEmpty
                  ? Center(child: Text('لا توجد رسائل بعد', style: TextStyle(color: AppColors.textColor)))
                  : ListView.builder(
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
                                '${msg['message']} - ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(msg['timestamp']))}',
                                style: TextStyle(color: isSentByMe ? AppColors.textColor : Colors.blue),
                              ),
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
                    decoration: InputDecoration(
                      labelText: 'اكتب رسالتك',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      filled: true,
                      fillColor: Colors.white,
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
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  Navigator.pushReplacementNamed(context, '/home', arguments: currentUser);
                }
              },
              child: Text('عودة', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                minimumSize: Size(200, 50),
              ),
            ),
          ],
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
