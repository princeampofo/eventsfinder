import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// This class handles all database operations
class DatabaseHelper {
  static Database? _database;

  // Get database instance
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'local_events.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  // Create all tables
  Future<void> _createTables(Database db, int version) async {
    // Create users table
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        password TEXT
      )
    ''');

    // Create events table
    await db.execute('''
      CREATE TABLE events(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        type TEXT,
        date TEXT,
        city TEXT,
        venue TEXT,
        price REAL,
        description TEXT,
        imageUrl TEXT
      )
    ''');

    // Create tickets table
    await db.execute('''
      CREATE TABLE tickets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        eventId INTEGER,
        userId INTEGER,
        qrCode TEXT,
        purchaseDate TEXT
      )
    ''');

    // Create favorites table
    await db.execute('''
      CREATE TABLE favorites(
        userId INTEGER,
        eventId INTEGER
      )
    ''');

    // Insert demo user
    await db.insert('users', {
      'name': 'Demo User',
      'email': 'demo@example.com',
      'password': '1234',
    });

    // Insert dummy events
    await db.insert('events', {
      'title': 'Indie Night at BlueHall',
      'type': 'Concert',
      'date': '2025-11-01',
      'city': 'Atlanta',
      'venue': 'Downtown Arena',
      'price': 25.0,
      'description': 'A live indie concert featuring local bands.',
      'imageUrl': 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800',
    });

    await db.insert('events', {
      'title': 'Photography 101',
      'type': 'Workshop',
      'date': '2025-11-05',
      'city': 'Austin',
      'venue': 'Creative Studio',
      'price': 50.0,
      'description': 'Learn the basics of photography from professionals.',
      'imageUrl': 'https://images.unsplash.com/photo-1452587925148-ce544e77e70d?w=800',
    });

    await db.insert('events', {
      'title': 'Community Soccer Match',
      'type': 'Sports',
      'date': '2025-11-10',
      'city': 'Chicago',
      'venue': 'City Stadium',
      'price': 15.0,
      'description': 'Join us for an exciting community soccer match.',
      'imageUrl': 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?w=800',
    });

    await db.insert('events', {
      'title': 'Tech Networking Night',
      'type': 'Meetup',
      'date': '2025-11-15',
      'city': 'New York',
      'venue': 'Tech Hub',
      'price': 0.0,
      'description': 'Network with tech professionals and entrepreneurs.',
      'imageUrl': 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?w=800',
    });

    await db.insert('events', {
      'title': 'Gallery Opening',
      'type': 'Art',
      'date': '2025-11-20',
      'city': 'Los Angeles',
      'venue': 'Modern Art Gallery',
      'price': 20.0,
      'description': 'Experience contemporary art from emerging artists.',
      'imageUrl': 'https://images.unsplash.com/photo-1531243269054-5ebf6f34081e?w=800',
    });

    await db.insert('events', {
      'title': 'Jazz Evening',
      'type': 'Concert',
      'date': '2025-11-25',
      'city': 'New Orleans',
      'venue': 'Jazz Club',
      'price': 30.0,
      'description': 'Enjoy a night of smooth jazz performances.',
      'imageUrl': 'https://images.unsplash.com/photo-1508214751196-bcfd4ca60f91?w=800',
    });

    await db.insert('events', {
      'title': 'Culinary Arts Workshop',
      'type': 'Workshop',
      'date': '2025-11-30',
      'city': 'San Francisco',
      'venue': 'Culinary School',
      'price': 75.0,
      'description': 'Master the art of cooking with expert chefs.',
      'imageUrl': 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=800',
    });

    await db.insert('events', {
      'title': 'Marathon 2025',
      'type': 'Sports',
      'date': '2025-12-05',
      'city': 'Boston',
      'venue': 'City Park',
      'price': 40.0,
      'description': 'Participate in the annual city marathon event.',
      'imageUrl': 'https://images.unsplash.com/photo-1508609349937-5ec4ae374ebf?w=800',
    });
  }
}