import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TextViewerScreen extends StatefulWidget {
  final String textUrl;

  TextViewerScreen({required this.textUrl});

  @override
  _TextViewerScreenState createState() => _TextViewerScreenState();
}

class _TextViewerScreenState extends State<TextViewerScreen> {
  String _content = 'جاري تحميل النص...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  Future<void> _loadText() async {
    try {
      final response = await http.get(Uri.parse(widget.textUrl));
      if (response.statusCode == 200) {
        setState(() {
          _content = response.body;
          _isLoading = false;
        });
      } else {
        setState(() {
          _content = 'فشل في جلب النص';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _content = 'خطأ: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('عرض النص'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SelectableText(
                    _content,
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
      ),
    );
  }
}