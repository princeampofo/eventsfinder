import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';

class EventDetailsScreen extends StatefulWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final DatabaseService dbService = DatabaseService();
  final StorageService storageService = StorageService();
  
  late Event event;
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    event = widget.event;
  }

  // Load user ID and check favorite status
  void loadUserAndFavoriteStatus() async {
    currentUserId = await storageService.getUserId();
    
    if (currentUserId != null) {
      bool isFav = await dbService.isFavorite(event.id!, currentUserId!);
      setState(() {
        event.isFavorite = isFav ? 1 : 0;
      });
    }
  }

  // Toggle favorite
  void toggleFavorite() async { 
    bool newStatus = event.isFavorite == 0;
    await dbService.toggleFavorite(event.id!, currentUserId!, newStatus);
    
    setState(() {
      event.isFavorite = newStatus ? 1 : 0;
    });
  }

  // Get ticket
  void getTicket() async {
    int? userId = await storageService.getUserId();
    
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    // Generate QR code (simple string for now)
    String qrCode = 'TICKET-${event.id}-$userId-${DateTime.now().millisecondsSinceEpoch}';
    
    // Add ticket to database
    await dbService.addTicket({
      'eventId': event.id,
      'userId': userId,
      'qrCode': qrCode,
      'purchaseDate': DateTime.now().toString().split(' ')[0],
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ticket purchased successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              event.isFavorite == 1 ? Icons.star : Icons.star_border,
              color: Colors.white,
            ),
            onPressed: toggleFavorite,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event image
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              Image.network(
                event.imageUrl!,
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF4F46E5),
                          const Color(0xFF4F46E5).withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.event,
                        size: 80,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              )
            else
              Container(
                width: double.infinity,
                height: 250,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4F46E5),
                      const Color(0xFF4F46E5).withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.event,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Type badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      event.type,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Date and time
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Date & Time',
                    '${event.date} at ${event.time}',
                  ),
                  const SizedBox(height: 16),
                  
                  // Location
                  _buildInfoRow(
                    Icons.location_on,
                    'Location',
                    '${event.venue}, ${event.city}',
                  ),
                  const SizedBox(height: 16),
                  
                  // Price
                  _buildInfoRow(
                    Icons.attach_money,
                    'Price',
                    event.price == 0 ? 'Free' : '\$${event.price.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 24),
                  
                  // Description
                  const Text(
                    'About',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Get Ticket button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: getTicket,
                      icon: const Icon(Icons.confirmation_number),
                      label: const Text(
                        'Get Ticket',
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF4F46E5),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}