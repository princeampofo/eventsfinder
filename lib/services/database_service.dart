import '../database/db_helper.dart';
import '../models/event.dart';
import '../models/user.dart';

// Service class for database operations
class DatabaseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();


  // Register new user
  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user);
  }

  // Get user by email
  Future<User?> getUserByEmail(String email) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (maps.isEmpty) {
      return null;
    }
    return User.fromMap(maps.first);
  }
}