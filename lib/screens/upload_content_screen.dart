import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/services/storage_service.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:alson_education/widgets/app_bar_widget.dart';

class UploadContentScreen extends StatefulWidget {
  const UploadContentScreen({super.key});

  @override
  State<UploadContentScreen> createState() => _UploadContentScreenState();
}

class _UploadContentScreenState extends State<UploadContentScreen> {
  final _titleController = TextEditingController();
  final _departmentController = TextEditingController();
  final _divisionController = TextEditingController();
  FilePickerResult? _fileResult;
  FilePickerResult? _posterResult;

  Future<void> uploadContent() async {
    final appState = Provider.of<AppState>(context, listen: false);
    if (!appState.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only admins can upload content')));
      return;
    }

    if (_fileResult == null ||
        _fileResult!.files.single.path == null ||
        _titleController.text.isEmpty ||
        _departmentController.text.isEmpty ||
        _divisionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please provide all required fields')));
      return;
    }

    try {
      final file = _fileResult!.files.single;
      final bytes = await File(file.path!).readAsBytes();
      if (bytes.isEmpty) {
        throw Exception('File is empty');
      }

      final filePath = await StorageService.saveFile(file.name, bytes);
      String? posterPath;
      if (_posterResult != null && _posterResult!.files.single.path != null) {
        final posterBytes = await File(_posterResult!.files.single.path!).readAsBytes();
        posterPath = await StorageService.saveFile(_posterResult!.files.single.name, posterBytes);
      }

      final content = Content(
        id: DateTime.now().toString(),
        title: _titleController.text,
        filePath: filePath,
        posterPath: posterPath,
        fileType: file.name.split('.').last.toLowerCase(),
        uploadedBy: appState.currentUserCode!,
        uploadDate: DateTime.now().toString(),
        department: _departmentController.text,
        division: _divisionController.text,
      );
      await DatabaseService().insertContent(content);

      if (file.name.endsWith('.xlsx') || file.name.endsWith('.xls')) {
        var excel = Excel.decodeBytes(bytes);
        var sheet = excel.tables.entries.first.value;
        List<Map<String, dynamic>> excelData = [];
        for (var row in sheet.rows.skip(1)) {
          if (row.length >= 2) {
            excelData.add({
              'code': row[0]?.value.toString(),
              'username': row[1]?.value.toString(),
              'department': _departmentController.text,
              'division': _divisionController.text,
            });
          }
        }

        for (var row in excelData) {
          await DatabaseService().insertUser(User(
            code: row['code'] ?? '',
            username: row['username'] ?? '',
            department: row['department'] ?? '',
            division: row['division'] ?? '',
            role: 'user',
            password: row['code'] ?? '',
          ));
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Content uploaded successfully')));
      _titleController.clear();
      _departmentController.clear();
      _divisionController.clear();
      setState(() {
        _fileResult = null;
        _posterResult = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: CustomAppBar(AppStrings.get('upload_content', appState.language), isAdmin: appState.isAdmin),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('title', appState.language),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _departmentController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('department', appState.language),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _divisionController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('division', appState.language),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['xlsx', 'xls', 'pdf', 'jpg', 'png'],
                  );
                  setState(() {
                    _fileResult = result;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppStrings.get('pick_file', appState.language)),
              ),
              if (_fileResult != null) Text('Selected: ${_fileResult!.files.single.name}'),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['jpg', 'png'],
                  );
                  setState(() {
                    _posterResult = result;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Pick Poster'),
              ),
              if (_posterResult != null) Text('Selected Poster: ${_posterResult!.files.single.name}'),
              const SizedBox(height: 20),
              ElevatedButton(
                on: uploadContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(AppStrings.get('upload_content', appState.language)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
