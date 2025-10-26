import 'package:sqflite/sqflite.dart';
import '../database/db_helper.dart';
import '../models/event.dart';
import '../models/user.dart';
import 'location.dart';

// Service class for database operations
class DatabaseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LocationService _locationService = LocationService();


  // Register new user
  Future<int> registerUser(Map<String, dynamic> user) async {
    final db = await _dbHelper.database;
    return await db.insert('users', user);
  }

  // Insert event
  Future<int> insertEvent(Map<String, dynamic> event) async {
    final db = await _dbHelper.database;
    return await db.insert('events', event);
  }

  // Toggle favorite status for specific user
  Future<void> toggleFavorite(int eventId, int userId, bool status) async {
    final db = await _dbHelper.database;
    
    if (status) {
      // Add to favorites table
      await db.insert(
        'favorites',
        {'userId': userId, 'eventId': eventId},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Remove from favorites table
      await db.delete(
        'favorites',
        where: 'userId = ? AND eventId = ?',
        whereArgs: [userId, eventId],
      );
    }
  }

  // Get favorite events for specific user
  Future<List<Event>> getFavorites(int userId) async {
    final db = await _dbHelper.database;
    
    // Join favorites table with events table
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT events.* 
      FROM events 
      INNER JOIN favorites ON events.id = favorites.eventId 
      WHERE favorites.userId = ?
    ''', [userId]);
    
    List<Event> events = [];
    for (var map in maps) {
      events.add(Event.fromMap(map));
    }
    return events;
  }

  // Check if event is favorited by user
  Future<bool> isFavorite(int eventId, int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> result = await db.query(
      'favorites',
      where: 'userId = ? AND eventId = ?',
      whereArgs: [userId, eventId],
    );
    return result.isNotEmpty;
  }

  // Get events with favorite status for specific user
  Future<List<Map<String, dynamic>>> getEventsWithFavoriteStatus(int userId) async {
    final db = await _dbHelper.database;
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT events.*, 
             CASE WHEN favorites.eventId IS NOT NULL THEN 1 ELSE 0 END as isFavorite
      FROM events 
      LEFT JOIN favorites ON events.id = favorites.eventId AND favorites.userId = ?
    ''', [userId]);
    
    return maps;
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

  // Get tickets for user
  Future<List<Map<String, dynamic>>> getUserTickets(int userId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> tickets = await db.rawQuery('''
      SELECT tickets.*, events.title, events.date, events.venue 
      FROM tickets 
      JOIN events ON tickets.eventId = events.id 
      WHERE tickets.userId = ?
    ''', [userId]);
    
    return tickets;
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

  // get user by id
  Future<User?> getUserById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) {
      return null;
    }
    return User.fromMap(maps.first);
  }

  // Get nearby events based on user location
  Future<List<Event>> getNearbyEvents({
    required double userLat,
    required double userLon,
    required int userId,
    double radiusKm = 100, // Default 100km radius
  }) async {
    // Get all events with favorite status
    final List<Map<String, dynamic>> eventMaps = 
        await getEventsWithFavoriteStatus(userId);
    
    List<Event> nearbyEvents = [];
    
    for (var map in eventMaps) {
      Event event = Event.fromMap(map);
      
      // Only include events with coordinates
      if (event.latitude != null && event.longitude != null) {
        // Calculate distance
        double distance = _locationService.calculateDistance(
          userLat,
          userLon,
          event.latitude!,
          event.longitude!,
        );
        
        // Check if within radius
        if (distance <= radiusKm) {
          event.distanceFromUser = distance;
          nearbyEvents.add(event);
        }
      }
    }
    
    // Sort by distance (closest first)
    nearbyEvents.sort((a, b) => 
      a.distanceFromUser!.compareTo(b.distanceFromUser!)
    );
    
    return nearbyEvents;
  }
}