import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/services/storage_service.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/constants/strings.dart';

class UploadContentScreen extends StatefulWidget {
  @override
  _UploadContentScreenState createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _titleController = TextEditingController();

  Future<void> uploadContent(FilePickerResult? result) async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (result != null && result.files.single.path != null && _titleController.text.isNotEmpty) {
      final file = result.files.single;
      final bytes = await File(file.path!).readAsBytes();
      final filePath = await StorageService.saveFile(file.name, bytes);
      final content = Content(
        title: _titleController.text,
        filePath: filePath,
        fileType: file.name.split('.').last,
        uploadedBy: appState.currentUserCode!,
        uploadDate: DateTime.now().toString(),
      );
      await DatabaseService.instance.insertContent(content);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Content uploaded')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('upload_content', appState.language))),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(labelText: AppStrings.get('title', appState.language), border: OutlineInputBorder()),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                uploadContent(result);
              },
              child: Text(AppStrings.get('pick_file', appState.language)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}