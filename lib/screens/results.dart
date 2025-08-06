import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  Result? _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    setState(() => _isLoading = true);
    try {
      final user = Provider.of<UserProvider>(context, listen: false).user!;
      final data = await getResults(user.code);
      setState(() => _result = data);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل في جلب النتائج')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user!;

    return Scaffold(
      appBar: AppBarWidget(isAdmin: user.role == 'admin'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'النتائج',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: primaryColor,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 16),
            _result == null
                ? const Center(child: Text('لا توجد نتائج', style: TextStyle(color: textColor, fontFamily: 'Cairo')))
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('المادة: ${_result!.subject}', style: const TextStyle(fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                        Text('الدرجة: ${_result!.score}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                        Text('التاريخ: ${_result!.date}', style: const TextStyle(color: textColor, fontFamily: 'Cairo')),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}