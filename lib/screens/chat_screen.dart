import 'package:flutter/material.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart' as app_user;
import 'package:alson_education/models/message.dart';

class ChatScreen extends StatefulWidget {
  final ApiService apiService;
  final app_user.AppUser user;

  ChatScreen({required this.apiService, required this.user});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<Message> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startAutoRefresh();
    
    // إضافة listener للتمرير التلقائي
    _scrollController.addListener(() {
      if (_scrollController.position.maxScrollExtent - _scrollController.position.pixels <= 100) {
        _scrollToBottom();
      }
    });
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await widget.apiService.getChatMessages('', '');
      setState(() {
        _messages = messages;
      });
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب الرسائل: $e')),
      );
    }
  }

  void _startAutoRefresh() {
    Future.delayed(Duration(seconds: 10), () {
      if (mounted) {
        _loadMessages();
        _startAutoRefresh();
      }
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final success = await widget.apiService.sendMessage(
        senderId: widget.user.code,
        department: widget.user.department,
        division: widget.user.division,
        content: _messageController.text,
      );

      if (success) {
        _messageController.clear();
        _loadMessages();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إرسال الرسالة: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteMessage(Message message) async {
    if (message.senderId != widget.user.code && widget.user.role != 'admin') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('غير مصرح لك بحذف هذه الرسالة')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تأكيد الحذف', textAlign: TextAlign.center),
        content: Text('هل أنت متأكد من حذف هذه الرسالة؟', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم حذف الرسالة بنجاح')),
        );
        _loadMessages();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في حذف الرسالة')),
        );
      }
    }
  }

  Widget _buildScrollToBottomButton() {
    return FloatingActionButton(
      onPressed: _scrollToBottom,
      mini: true,
      child: Icon(Icons.arrow_downward),
      backgroundColor: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد رسائل بعد\nكن أول من يبدأ المحادثة',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == widget.user.code;

                          return GestureDetector(
                            onLongPress: () => _deleteMessage(message),
                            child: Container(
                              margin: EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                children: [
                                  if (!isMe) ...[
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.primary,
                                      child: Text(
                                        message.username[0].toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                  ],
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isMe
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).cardColor,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(
                                            blurRadius: 2,
                                            color: Colors.black12,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          if (!isMe)
                                            Text(
                                              message.username,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: isMe ? Colors.white70 : Theme.of(context).colorScheme.primary,
                                              ),
                                            ),
                                          SizedBox(height: 4),
                                          Text(
                                            message.content,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: isMe ? Colors.white : Colors.black87,
                                            ),
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            message.timestamp,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isMe ? Colors.white70 : Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isMe) ...[
                                    SizedBox(width: 8),
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      child: Text(
                                        'أنت',
                                        style: TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(top: BorderSide(color: Colors.grey[300]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك هنا...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        maxLines: 3,
                        minLines: 1,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8),
                    _isLoading
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                            onPressed: _sendMessage,
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              padding: EdgeInsets.all(12),
                            ),
                          ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 80,
            right: 16,
            child: _buildScrollToBottomButton(),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
