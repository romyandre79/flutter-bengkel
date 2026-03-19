import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:kreatif_otopart/core/utils/password_helper.dart';

void main() async {
  // Initialize FFI
  sqfliteFfiInit();
  var databaseFactory = databaseFactoryFfi;

  // Get DB path
  final userProfile = Platform.environment['USERPROFILE'];
  if (userProfile == null) {
    print('Error: USERPROFILE not found');
    return;
  }
  final dbPath = p.join(userProfile, 'Documents', 'kreatif_otopart.db');

  if (!await File(dbPath).exists()) {
    print('Error: Database file does not exist');
    return;
  }

  final db = await databaseFactory.openDatabase(dbPath);

  try {
    final String newPassword = 'admin';
    final String newHash = PasswordHelper.hashPassword(newPassword);
    
    await db.update(
      'users',
      {
        'password_hash': newHash,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'username = ?',
      whereArgs: ['admin'],
    );
    
    print('SUCCESS: Password for "admin" has been reset to "admin"');
    print('New Hash: $newHash');
  } catch (e) {
    print('Error resetting password: $e');
  } finally {
    await db.close();
  }
}
