import 'package:flutter/material.dart';
import 'package:alson_education/utils/colors.dart';

class AdminCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final VoidCallback? onTap;

  const AdminCard({super.key, required this.title, required this.children, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor)),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}
