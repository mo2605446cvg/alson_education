import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:alson_education/database/database_helper.dart';

class ContentScreen extends StatefulWidget {
  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  List<Map<String, dynamic>> _contents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    setState(() => _isLoading = true);
    final db = await DatabaseHelper.instance.database;
    final contents = await db.query('content');
    setState(() {
      _contents = contents;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('المحتوى التعليمي')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _contents.isEmpty
              ? Center(child: Text('لا يوجد محتوى متاح'))
              : ListView.builder(
                  itemCount: _contents.length,
                  itemBuilder: (context, index) => _buildContentItem(_contents[index]),
                ),
    );
  }

  Widget _buildContentItem(Map<String, dynamic> content) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(content['title']),
        subtitle: Text('${content['file_type']} - ${content['upload_date']}'),
        trailing: IconButton(
          icon: Icon(Icons.download),
          onPressed: () => OpenFile.open(content['file_path']),
        ),
      ),
    );
  }
}