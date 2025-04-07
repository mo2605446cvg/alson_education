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
  List<Content> contents = [];

  @override
  void initState() {
    super.initState();
    loadContents();
  }

  Future<void> loadContents() async {
    final db = DatabaseService.instance;
    contents = await db.getContents();
    setState(() {});
  }

  Future<void> viewContent(Content content) async {
    final filePath = content.filePath;
    if (await File(filePath).exists()) {
      if (content.fileType == 'jpg' || content.fileType == 'png') {
        // عرض الصورة داخل التطبيق
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
        // فتح PDF أو نص باستخدام url_launcher
        final uri = Uri.file(filePath);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot open file')));
        }
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
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                contents.isEmpty
                    ? const Text('No content available', textAlign: TextAlign.center)
                    : SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ListView.builder(
                          itemCount: contents.length,
                          itemBuilder: (context, index) {
                            final content = contents[index];
                            return ListTile(
                              title: Text(content.title, textAlign: TextAlign.center),
                              subtitle: Text('Type: ${content.fileType}', textAlign: TextAlign.center),
                              onTap: () => viewContent(content),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
