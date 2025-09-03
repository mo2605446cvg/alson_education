import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatelessWidget {
  final String pdfUrl;

  PdfViewerScreen({required this.pdfUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('عرض ملف PDF'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: SfPdfViewer.network(
        pdfUrl,
        initialScrollOffset: Offset(0, 0),
        initialZoomLevel: 1.0,
        canShowScrollHead: true,
        canShowScrollStatus: true,
      ),
    );
  }
}