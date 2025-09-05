import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageViewerScreen extends StatefulWidget {
  final String imageUrl;

  ImageViewerScreen({required this.imageUrl});

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PhotoViewController _controller;
  double _scale = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = PhotoViewController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadImage,
            tooltip: 'تنزيل الصورة',
          ),
        ],
      ),
      body: GestureDetector(
        onDoubleTap: _toggleZoom,
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(widget.imageUrl),
          controller: _controller,
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3.0,
          initialScale: PhotoViewComputedScale.contained,
          backgroundDecoration: BoxDecoration(color: Colors.black),
          loadingBuilder: (context, event) => Center(
            child: CircularProgressIndicator(),
          ),
          errorBuilder: (context, error, stackTrace) => Center(
            child: Icon(Icons.error, color: Colors.white, size: 50),
          ),
        ),
      ),
    );
  }

  void _toggleZoom() {
    final newScale = _scale == 1.0 ? 2.0 : 1.0;
    _controller.scale = newScale;
    setState(() => _scale = newScale);
  }

  void _downloadImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('جاري تنزيل الصورة...')),
    );
    // إضافة كود التنزيل هنا
  }
}