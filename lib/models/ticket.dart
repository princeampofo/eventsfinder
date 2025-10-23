// Simple Ticket class to hold ticket data
class Ticket {
  int? id;
  int eventId;
  int userId;
  String qrCode;
  String purchaseDate;

  Ticket({
    this.id,
    required this.eventId,
    required this.userId,
    required this.qrCode,
    required this.purchaseDate,
  });

  // Convert Ticket to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'qrCode': qrCode,
      'purchaseDate': purchaseDate,
    };
  }

  // Create Ticket from Map
  factory Ticket.fromMap(Map<String, dynamic> map) {
    return Ticket(
      id: map['id'],
      eventId: map['eventId'],
      userId: map['userId'],
      qrCode: map['qrCode'],
      purchaseDate: map['purchaseDate'],
    );
  }
}