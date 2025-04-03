import 'package:flutter/material.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final Widget child;

  const DashboardCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            child,
          ],
        ),
      ),
    );
  }
}
