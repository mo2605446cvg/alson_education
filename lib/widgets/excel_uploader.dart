import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:alson_education/utils/colors.dart';
import 'package:uuid/uuid.dart';

class ExcelUploader extends StatefulWidget {
  final Function onUploadSuccess;

  const ExcelUploader({super.key, required this.onUploadSuccess});

  @override
  State<ExcelUploader> createState() => _ExcelUploaderState();
}

class _ExcelUploaderState extends State<ExcelUploader> {
  bool _isLoading = false;

  Future<void> _uploadExcel() async {
    setState(() => _isLoading = true);

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: false,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في قراءة الملف', style: TextStyle(color: AppColors.errorColor))),
        );
        setState(() => _isLoading = false);
        return;
      }

      try {
        final excel = Excel.decodeBytes(bytes);
        final db = DatabaseService.instance;
        final batch = await db.database.then((db) => db.batch());

        for (var table in excel.tables.keys) {
          final sheet = excel.tables[table]!;
          for (var row in sheet.rows.skip(1)) { // تخطي العنوان
            if (row.length >= 2) {
              final username = row[0]?.value.toString() ?? '';
              final password = row[1]?.value.toString() ?? '';
              final code = const Uuid().v4().substring(0, 8);

              batch.insert('users', {
                'code': code,
                'username': username,
                'department': table,
                'role': 'user',
                'password': password,
              });
            }
          }
        }

        await batch.commit();
        widget.onUploadSuccess();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('تم رفع المستخدمين بنجاح', style: TextStyle(color: Colors.green))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في معالجة الملف: $e', style: TextStyle(color: AppColors.errorColor))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لم يتم اختيار ملف', style: TextStyle(color: AppColors.errorColor))),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _isLoading
            ? CircularProgressIndicator(color: AppColors.primaryColor)
            : ElevatedButton(
                onPressed: _uploadExcel,
                child: Text('رفع ملف Excel', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  minimumSize: Size(200, 50),
                ),
              ),
        SizedBox(height: 10),
        Text(
          'الصيغة: العمود الأول: اسم المستخدم، العمود الثاني: كلمة المرور، اسم الورقة: القسم',
          style: TextStyle(fontSize: 14, color: AppColors.textColor),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
