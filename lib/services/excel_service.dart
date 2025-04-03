import 'package:excel/excel.dart';
import 'package:alson_education/services/database_service.dart';
import 'package:uuid/uuid.dart';

class ExcelService {
  final DatabaseService _db = DatabaseService.instance;

  Future<void> processExcel(List<int> bytes) async {
    final excel = Excel.decodeBytes(bytes);

    for (var table in excel.tables.keys) {
      final sheet = excel.tables[table]!;
      for (var row in sheet.rows.skip(1)) { // تخطي العنوان
        if (row.length >= 2) {
          final username = row[0]?.value.toString() ?? '';
          final password = row[1]?.value.toString() ?? '';
          final code = const Uuid().v4().substring(0, 8);

          await _db.insert('users', {
            'code': code,
            'username': username,
            'department': table,
            'role': 'user',
            'password': password,
          });
        }
      }
    }
  }
}
