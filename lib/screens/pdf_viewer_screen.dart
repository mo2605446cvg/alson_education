import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PDFViewerScreen extends StatelessWidget {
  final String url;
  const PDFViewerScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('عرض PDF', style: TextStyle(fontFamily: 'Cairo'))),
      body: PDFView(filePath: url, enableSwipe: true, swipeHorizontal: true),
    );
  }
}