import 'package:flutter/material.dart';
import 'package:alson_education/constants/colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final double elevation;

  CustomCard({required this.child, this.elevation = 5});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: child,
    );
  }
}