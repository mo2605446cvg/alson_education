import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/constants/strings.dart';
import 'package:alson_education/providers/app_state_provider.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key});

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  Future<void> viewContent(Content content) async {
    final filePath = content.filePath;
    if (await File(filePath).exists()) {
      try {
        if (content.fileType == 'jpg' || content.fileType == 'png') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text(content.title)),
                body: Center(child: Image.file(File(filePath))),
              ),
            ),
          );
        } else if (content.fileType == 'pdf' || content.fileType == 'txt') {
          final uri = Uri.file(filePath);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open file')));
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error opening file: $e')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File not found')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('content', appState.language)),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Content>>(
        future: DatabaseService().getContents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading content: ${snapshot.error}'));
          }
          final contents = snapshot.data ?? [];
          return contents.isEmpty
              ? const Center(child: Text('No content available'))
              : ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: contents.length,
                  itemBuilder: (context, index) {
                    final content = contents[index];
                    return ListTile(
                      title: Text(content.title, textAlign: TextAlign.center),
                      subtitle: Text('Type: ${content.fileType}', textAlign: TextAlign.center),
                      onTap: () => viewContent(content),
                    );
                  },
                );
        },
      ),
    );
  }
}
