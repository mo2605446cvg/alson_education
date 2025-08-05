
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:alson_education/components/app_bar.dart';
import 'package:alson_education/providers/user_provider.dart';
import 'package:alson_education/utils/api.dart';
import 'package:alson_education/utils/colors.dart';

class Results extends StatefulWidget {
  const Results({super.key});

  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  Result? _results;
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
      setState(() => _results = data);
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
            _isLoading
                ? const Text('جارٍ التحميل...', style: TextStyle(color: textColor, fontFamily: 'Cairo'))
                : _results != null
                    ? Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 384),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('الدرجة: ${_results!.score}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor, fontFamily: 'Cairo')),
                            const SizedBox(height: 8),
                            Text('المادة: ${_results!.subject}', style: const TextStyle(fontSize: 16, color: textColor, fontFamily: 'Cairo')),
                            const SizedBox(height: 8),
                            Text(
                              'التاريخ: ${DateFormat('dd/MM/yyyy', 'ar').format(DateTime.parse(_results!.date))}',
                              style: const TextStyle(fontSize: 16, color: textColor, fontFamily: 'Cairo'),
                            ),
                          ],
                        ),
                      )
                    : const Text('لا توجد نتائج', style: TextStyle(color: textColor, fontFamily: 'Cairo')),
          ],
        ),
      ),
    );
  }
}
