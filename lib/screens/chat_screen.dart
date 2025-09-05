import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isSending = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() => _isLoading = true);
      final messages = await widget.apiService.getChatMessages();
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في جلب الرسائل: $e')),
      );
    }
  }

  void _startAutoRefresh() {
    Future.delayed(Duration(seconds: 3), () {
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
    if (_messageController.text.isEmpty || _isSending) return;

    setState(() => _isSending = true);

    try {
      final success = await widget.apiService.sendMessage(
        senderId: widget.user.code,
        content: _messageController.text,
      );

      if (success) {
        _messageController.clear();
        _loadMessages();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال الرسالة بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إرسال الرسالة: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Future<void> _sendImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        _sendMediaMessage('صورة: ${image.name}', 'image');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في اختيار الصورة: $e')),
      );
    }
  }

  Future<void> _sendFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null) {
        _sendMediaMessage('ملف: ${result.files.single.name}', 'file');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في اختيار الملف: $e')),
      );
    }
  }

  Future<void> _sendMediaMessage(String content, String type) async {
    try {
      setState(() => _isSending = true);
      final success = await widget.apiService.sendMessage(
        senderId: widget.user.code,
        content: '[$type] $content',
      );

      if (success) {
        _loadMessages();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم إرسال الوسائط بنجاح')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في إرسال الوسائط: $e')),
      );
    } finally {
      setState(() => _isSending = false);
    }
  }

  Widget _buildMessageBubble(Message message, bool isMe) {
    final isImage = message.content.contains('[image]');
    final isFile = message.content.contains('[file]');
    final content = message.content.replaceAll('[image]', '').replaceAll('[file]', '');

    return Container(
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  radius: 16,
                  child: Text(
                    message.username.isNotEmpty ? message.username[0].toUpperCase() : '?',
                    style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 6),
              ],
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isMe ? Colors.blue[700] : Colors.grey[800],
                    borderRadius: BorderRadius.circular(16),
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
                            color: Colors.white70,
                          ),
                        ),
                      if (!isMe) SizedBox(height: 2),
                      
                      if (isImage)
                        Column(
                          children: [
                            Icon(Icons.image, size: 40, color: Colors.white),
                            SizedBox(height: 4),
                            Text(content, style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        )
                      else if (isFile)
                        Column(
                          children: [
                            Icon(Icons.insert_drive_file, size: 40, color: Colors.white),
                            SizedBox(height: 4),
                            Text(content, style: TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        )
                      else
                        Text(
                          content,
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      
                      SizedBox(height: 4),
                      Text(
                        _formatTimestamp(message.timestamp),
                        style: TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ),
              if (isMe) ...[
                SizedBox(width: 6),
                CircleAvatar(
                  backgroundColor: Colors.green[700],
                  radius: 16,
                  child: Text(
                    'أنت',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          
          // أزرار التفاعل
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(top: 4.0, right: 50),
              child: Row(
                children: [
                  _buildReactionButton('👍', message),
                  SizedBox(width: 4),
                  _buildReactionButton('❤️', message),
                  SizedBox(width: 4),
                  _buildReactionButton('😂', message),
                  SizedBox(width: 4),
                  _buildReactionButton('😮', message),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReactionButton(String emoji, Message message) {
    return GestureDetector(
      onTap: () => _addReaction(message, emoji),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(emoji, style: TextStyle(fontSize: 12)),
      ),
    );
  }

  Future<void> _addReaction(Message message, String emoji) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة التفاعل $emoji للرسالة'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return timestamp;
    }
  }

  Widget _buildMessageInput() {
    final isAdmin = widget.user.role == 'admin';

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        border: Border(top: BorderSide(color: Colors.grey[700]!)),
      ),
      child: isAdmin
          ? Column(
              children: [
                // أزرار الوسائط
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.image, color: Colors.blue),
                      onPressed: _sendImage,
                      tooltip: 'إرسال صورة',
                    ),
                    IconButton(
                      icon: Icon(Icons.attach_file, color: Colors.green),
                      onPressed: _sendFile,
                      tooltip: 'إرسال ملف',
                    ),
                    Spacer(),
                    if (_isLoading)
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4),
                // حقل إدخال الرسالة
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالتك هنا...',
                          hintStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide(color: Colors.blue),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          fillColor: Colors.grey[800],
                          filled: true,
                        ),
                        style: TextStyle(color: Colors.white),
                        maxLines: 3,
                        minLines: 1,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    SizedBox(width: 8),
                    _isSending
                        ? CircularProgressIndicator(color: Colors.white)
                        : IconButton(
                            icon: Icon(Icons.send, color: Colors.white),
                            onPressed: _sendMessage,
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              padding: EdgeInsets.all(12),
                              shape: CircleBorder(),
                            ),
                          ),
                  ],
                ),
              ],
            )
          : Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.orange, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'يمكنك فقط مشاهدة الرسائل. تواصل مع المدير للاستفسارات.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[850],
      appBar: AppBar(
        title: Text('الدردشة العامة', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadMessages,
            tooltip: 'تحديث المحادثة',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat, size: 64, color: Colors.white54),
                            SizedBox(height: 16),
                            Text(
                              'لا توجد رسائل بعد\nكن أول من يبدأ المحادثة',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(8),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final isMe = message.senderId == widget.user.code;
                          return _buildMessageBubble(message, isMe);
                        },
                      ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }
}