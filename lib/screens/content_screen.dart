import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/models/lesson.dart';
import 'package:alson_education/constants/strings.dart';
import 'package:alson_education/providers/app_state_provider.dart';

class ContentScreen extends StatefulWidget {
  @override
  _ContentScreenState createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  final _searchController = TextEditingController();
  List<Lesson> lessons = [];

  @override
  void initState() {
    super.initState();
    loadLessons();
  }

  Future<void> loadLessons([String query = '']) async {
    final db = DatabaseService.instance;
    lessons = query.isEmpty ? await db.getLessons() : await db.searchLessons(query);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.get('content', appState.language))),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(labelText: AppStrings.get('search', appState.language), border: OutlineInputBorder()),
              onChanged: (value) => loadLessons(value),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                return ListTile(
                  title: Text(lesson.title),
                  subtitle: Text(lesson.category),
                  trailing: IconButton(
                    icon: Icon(lesson.isFavorite ? Icons.favorite : Icons.favorite_border),
                    onPressed: () async {
                      await DatabaseService.instance.toggleFavoriteLesson(lesson.id);
                      loadLessons(_searchController.text);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}