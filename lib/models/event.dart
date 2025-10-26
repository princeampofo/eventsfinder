// Simple Event class to hold event data
class Event {
  int? id;
  String title;
  String type;
  String date;
  String time;
  String city;
  String venue;
  double price;
  String description;
  int? isFavorite;
  String? imageUrl;  // Add image URL field
  double? latitude; // Event latitude
  double? longitude; // Event longitude
  double? distanceFromUser;

  Event({
    this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.time,
    required this.city,
    required this.venue,
    required this.price,
    required this.description,
    this.isFavorite = 0,
    this.imageUrl,  // Optional image URL
    this.latitude,
    this.longitude,
    this.distanceFromUser,
  });

  // Convert Event to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'date': date,
      'time': time,
      'city': city,
      'venue': venue,
      'price': price,
      'description': description,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Create Event from Map
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      city: map['city'] ?? '',
      venue: map['venue'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      isFavorite: map['isFavorite'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
    );
  }
}