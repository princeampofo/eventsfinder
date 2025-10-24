import 'package:flutter/material.dart';
import '../services/database_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final DatabaseService dbService = DatabaseService();
  
  // Controllers
  final TextEditingController titleController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController venueController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();
  
  String selectedType = 'Concert';
  String? selectedDate;
  bool isLoading = false;
  
  final List<String> eventTypes = [
    'Concert',
    'Workshop',
    'Sports',
    'Meetup',
    'Art'
  ];

  // Show date picker
  void showDatePickerDialog() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    
    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate.toString().split(' ')[0];
      });
    }
  }

  // Publish event
  void publishEvent() async {
    String title = titleController.text.trim();
    String city = cityController.text.trim();
    String venue = venueController.text.trim();
    String priceText = priceController.text.trim();
    String description = descriptionController.text.trim();
    String imageUrl = imageUrlController.text.trim();

    // Validate fields
    if (title.isEmpty || city.isEmpty || venue.isEmpty || 
        priceText.isEmpty || description.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    double? price = double.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Insert event into database
    await dbService.insertEvent({
      'title': title,
      'type': selectedType,
      'date': selectedDate,
      'city': city,
      'venue': venue,
      'price': price,
      'description': description,
      'imageUrl': imageUrl.isEmpty ? 'https://images.unsplash.com/photo-1501281668745-f7f57925c3b4?w=800' : imageUrl,
    });

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Event published successfully!'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
      // Clear form
      titleController.clear();
      cityController.clear();
      venueController.clear();
      priceController.clear();
      descriptionController.clear();
      imageUrlController.clear();
      descriptionController.clear();
      setState(() {
        selectedDate = null;
        selectedType = 'Concert';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Event'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Event Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Title field
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Type dropdown
            DropdownButtonFormField<String>(
              initialValue: selectedType,
              decoration: InputDecoration(
                labelText: 'Event Type',
                prefixIcon: const Icon(Icons.category),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: eventTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            
            // Date picker
            InkWell(
              onTap: showDatePickerDialog,
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Event Date',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  selectedDate ?? 'Select date',
                  style: TextStyle(
                    color: selectedDate == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // City field
            TextField(
              controller: cityController,
              decoration: InputDecoration(
                labelText: 'City',
                prefixIcon: const Icon(Icons.location_city),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Venue field
            TextField(
              controller: venueController,
              decoration: InputDecoration(
                labelText: 'Venue',
                prefixIcon: const Icon(Icons.place),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Price field
            TextField(
              controller: priceController,
              decoration: InputDecoration(
                labelText: 'Price',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            // Description field
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // Image URL field
            TextField(
              controller: imageUrlController,
              decoration: InputDecoration(
                labelText: 'Image URL (optional)',
                prefixIcon: const Icon(Icons.image),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),
            // Publish button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: isLoading ? null : publishEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Publish Event',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    cityController.dispose();
    venueController.dispose();
    priceController.dispose();
    descriptionController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }
}