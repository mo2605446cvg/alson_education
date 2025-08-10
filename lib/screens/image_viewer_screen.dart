import 'package:flutter/material.dart';

class ImageViewerScreen extends StatelessWidget {
  final String url;
  const ImageViewerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عرض الصورة', style: TextStyle(fontFamily: 'Cairo'))),
      body: Center(child: Image.network(url)),
    );
  }
}