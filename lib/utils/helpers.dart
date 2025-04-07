import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, {Color color = Colors.red}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message, style: TextStyle(color: color))));
}