import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TextViewerScreen extends StatefulWidget {
  final String url;
  const TextViewerScreen({super.key, required this.url});

  @override
  _TextViewerScreenState createState() => _TextViewerScreenState();
}

class _TextViewerScreenState extends State<TextViewerScreen> {
  String _content = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchText();
  }

  Future<void> _fetchText() async {
    try {
      final response = await http.get(Uri.parse(widget.url));
      if (response.statusCode == 200) {
        setState(() {
          _content = response.body;
          _loading = false;
        });
      }
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عرض النص', style: TextStyle(fontFamily: 'Cairo'))),
      body: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(child: Text(_content, style: const TextStyle(fontFamily: 'Cairo'))),
    );
  }
}