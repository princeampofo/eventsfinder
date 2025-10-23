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

  // Toggle favorite status
  Future<void> toggleFavorite(int id, bool status) async {
    final db = await _dbHelper.database;
    await db.update(
      'events',
      {'isFavorite': status ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Get filtered events
  Future<List<Event>> getFilteredEvents({
    String? type,
    String? date,
    String? city,
  }) async {
    final db = await _dbHelper.database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (type != null && type != 'All') {
      whereClause += 'type = ?';
      whereArgs.add(type);
    }
    
    if (date != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date = ?';
      whereArgs.add(date);
    }
    
    if (city != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'city = ?';
      whereArgs.add(city);
    }
    
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
    );
    
    List<Event> events = [];
    for (var map in maps) {
      events.add(Event.fromMap(map));
    }
    return events;
  }

  // Search events by title
  Future<List<Event>> searchEventsByTitle(String query) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'events',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
    );
    
    List<Event> events = [];
    for (var map in maps) {
      events.add(Event.fromMap(map));
    }
    return events;
  }

  // Get distinct cities
  Future<List<String>> getCities() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT city FROM events ORDER BY city'
    );
    
    List<String> cities = [];
    for (var map in maps) {
      cities.add(map['city']);
    }
    return cities;
  }

  // Get all events
  Future<List<Event>> getEvents() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('events');
    
    List<Event> events = [];
    for (var map in maps) {
      events.add(Event.fromMap(map));
    }
    return events;
  }


   // Add ticket
  Future<int> addTicket(Map<String, dynamic> ticket) async {
    final db = await _dbHelper.database;
    return await db.insert('tickets', ticket);
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