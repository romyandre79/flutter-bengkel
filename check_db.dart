import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() async {
  // Initialize FFI
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  // Get DB path (Documents folder on Windows)
  // On Windows, USERPROFILE environment variable is usually used
  final userProfile = Platform.environment['USERPROFILE'];
  if (userProfile == null) {
    print('Error: USERPROFILE not found');
    return;
  }
  
  final dbPath = p.join(userProfile, 'Documents', 'kreatif_otopart.db');
  print('Checking database at: $dbPath');

  if (!await File(dbPath).exists()) {
    print('Error: Database file does not exist');
    return;
  }

  final db = await databaseFactory.openDatabase(dbPath);

  try {
    final List<Map<String, dynamic>> users = await db.query('users');
    print('\nFound ${users.length} users:');
    for (var user in users) {
      print('ID: ${user['id']}, Username: "${user['username']}", Role: ${user['role']}, Active: ${user['is_active']}');
      print('  Hash: ${user['password_hash']}');
      print('  Updated At: ${user['updated_at']}');
      print('---');
    }
  } catch (e) {
    print('Error querying users: $e');
  } finally {
    await db.close();
  }
}
