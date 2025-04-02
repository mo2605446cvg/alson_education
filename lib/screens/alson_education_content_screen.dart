import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:alson_education/database/alson_education_database.dart';

class AlsonEducationContentScreen extends StatefulWidget {
  const AlsonEducationContentScreen({super.key});

  @override
  _AlsonEducationContentScreenState createState() => _AlsonEducationContentScreenState();
}

class _AlsonEducationContentScreenState extends State<AlsonEducationContentScreen> {
  List<Map<String, dynamic>> _contents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadContents();
  }

  Future<void> _loadContents() async {
    setState(() => _isLoading = true);
    final db = await AlsonEducationDatabase.instance.database;
    _contents = await db.query('content');
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المحتوى التعليمي')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.pushNamed(context, '/upload-content'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contents.isEmpty
              ? const Center(child: Text('لا يوجد محتوى متاح'))
              : ListView.builder(
                  itemCount: _contents.length,
                  itemBuilder: (context, index) => _buildContentItem(_contents[index]),
                ),
    );
  }

  Widget _buildContentItem(Map<String, dynamic> content) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(content['title']),
        subtitle: Text('${content['file_type']} - ${content['upload_date']}'),
        trailing: IconButton(
          icon: const Icon(Icons.download),
          onPressed: () => OpenFile.open(content['file_path']),
        ),
      ),
    );
  }
}
