import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/models/content.dart';
import 'package:alson_education/constants/app_strings.dart';
import 'package:alson_education/providers/app_state_provider.dart';
import 'package:alson_education/widgets/app_bar_widget.dart';

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
    final department = appState.currentUserDepartment ?? '';
    final division = appState.currentUserDivision ?? '';

    return Scaffold(
      appBar: CustomAppBar(AppStrings.get('content', appState.language), isAdmin: appState.isAdmin),
      body: FutureBuilder<List<Content>>(
        future: DatabaseService().getContents(department, division: division),
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
              : GridView.builder(
                  padding: const EdgeInsets.all(20.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: contents.length,
                  itemBuilder: (context, index) {
                    final content = contents[index];
                    return Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        onTap: () => viewContent(content),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: content.posterPath != null && File(content.posterPath!).existsSync()
                                  ? Image.file(
                                      File(content.posterPath!),
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, size: 50),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                content.title,
                                style: Theme.of(context).textTheme.titleMedium,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Type: ${content.fileType}',
                                style: Theme.of(context).textTheme.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
