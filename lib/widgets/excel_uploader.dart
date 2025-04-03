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
    final result = await FilePicker.platform.pickFiles(allowedExtensions: ['xlsx']);
    if (result != null) {
      final file = result.files.first;
      final bytes = file.bytes;
      final excel = Excel.decodeBytes(bytes!);

      final db = DatabaseService.instance;
      for (var table in excel.tables.keys) {
        final sheet = excel.tables[table]!;
        for (var row in sheet.rows.skip(1)) { // تخطي العنوان
          if (row.length >= 2) { // التأكد من وجود بيانات كافية
            final username = row[0]?.value.toString() ?? '';
            final password = row[1]?.value.toString() ?? '';
            final code = const Uuid().v4().substring(0, 8);

            await db.insert('users', {
              'code': code,
              'username': username,
              'department': table, // اسم الورقة كقسم
              'role': 'user',
              'password': password,
            });
          }
        }
      }

      widget.onUploadSuccess();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تم رفع المستخدمين بنجاح', style: TextStyle(color: Colors.green))));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('لم يتم اختيار ملف', style: TextStyle(color: Colors.red))));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _uploadExcel,
          child: _isLoading ? CircularProgressIndicator(color: Colors.white) : Text('رفع ملف Excel'),
          style: ElevatedButton.styleFrom(primary: AppColors.primaryColor, minimumSize: Size(200, 50)),
        ),
        Text('الصيغة: العمود الأول: اسم المستخدم، العمود الثاني: كلمة المرور، اسم الورقة: القسم',
            style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }
}
