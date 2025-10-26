import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../services/location.dart';
import '../models/event.dart';
import 'event_details.dart';
import 'package:geolocator/geolocator.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final DatabaseService dbService = DatabaseService();
  final StorageService storageService = StorageService();
  final LocationService locationService = LocationService();
  
  List<Event> allEvents = [];
  List<Event> filteredEvents = [];
  List<String> cities = [];
  int? currentUserId;
  Position? userLocation;
  
  String selectedType = 'All';
  String? selectedCity;
  String? selectedDate;
  String searchQuery = '';
  
  bool isLoading = true;
  
  final List<String> eventTypes = [
    'All',
    'Near Me',
    'Concert',
    'Workshop',
    'Sports',
    'Meetup',
    'Art'
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // Load events and cities from database
  Future<void> loadData() async {
    setState(() {
      isLoading = true;
    });
    
    // Get current user ID
    currentUserId = await storageService.getUserId();
    
    if (currentUserId != null) {
      // Get all events with favorite status for this user
      final List<Map<String, dynamic>> eventMaps = 
          await dbService.getEventsWithFavoriteStatus(currentUserId!);
      
      allEvents = [];
      for (var map in eventMaps) {
        allEvents.add(Event.fromMap(map));
      }
      
      filteredEvents = allEvents;
      
      // Get all cities
      cities = await dbService.getCities();
    }
    
    setState(() {
      isLoading = false;
    });
  }

  // Apply filters
  void applyFilters() async {
    setState(() {
      isLoading = true;
    });
    
    if (searchQuery.isNotEmpty) {
      // Search by title
      filteredEvents = await dbService.searchEventsByTitle(searchQuery);
    } else if (selectedType == 'Near Me') {
      // Show nearby events
      await loadNearbyEvents();
      setState(() {
        isLoading = false;
      });
      return;
    } else if (selectedType != 'All' || selectedDate != null || selectedCity != null) {
      // Apply filters
      filteredEvents = await dbService.getFilteredEvents(
        type: selectedType == 'All' ? null : selectedType,
        date: selectedDate,
        city: selectedCity,
      );
    } else {
      // Show all events
      filteredEvents = allEvents;
    }
    
    setState(() {
      isLoading = false;
    });
  }

  // Load nearby events based on user location
  Future<void> loadNearbyEvents() async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to see nearby events')),
      );
      filteredEvents = [];
      return;
    }

    // Check if we have cached location
    if (userLocation == null) {
      // Get user location
      Position? location = await locationService.getUserLocation();
      
      if (location == null) {
        // Show permission dialog
        showLocationPermissionDialog();
        filteredEvents = [];
        return;
      }
      
      userLocation = location;
    }
    
    // Get nearby events
    filteredEvents = await dbService.getNearbyEvents(
      userLat: userLocation!.latitude,
      userLon: userLocation!.longitude,
      userId: currentUserId!,
      radiusKm: 100, // 100km radius
    );
    
    if (filteredEvents.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No events found within 100km')),
      );
    }
  }

  // Show location permission dialog
  void showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'To see nearby events, please enable location permissions. '
          'This allows us to show you events happening near your current location.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Open Settings'),
            onPressed: () {
              Navigator.pop(context);
              locationService.openSettings();
            },
          ),
        ],
      ),
    );
  }

  // Toggle favorite
  void toggleFavorite(Event event) async {
    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to add favorites')),
      );
      return;
    }
    
    bool newStatus = event.isFavorite == 0;
    await dbService.toggleFavorite(event.id!, currentUserId!, newStatus);
    
    setState(() {
      event.isFavorite = newStatus ? 1 : 0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus ? 'Added to favorites' : 'Removed from favorites'),
      ),
    );
  }

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
      applyFilters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Events'),
        backgroundColor: const Color(0xFF4F46E5),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await loadData();
        },
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search events by title...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              searchQuery = '';
                            });
                            applyFilters();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                  applyFilters();
                },
              ),
            ),
            
            // Type filter chips
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: eventTypes.length,
                itemBuilder: (context, index) {
                  String type = eventTypes[index];
                  bool isSelected = selectedType == type;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (type == 'Near Me') ...[
                            const Icon(Icons.near_me, size: 16, color: Colors.white),
                            const SizedBox(width: 4),
                          ],
                          Text(type),
                        ],
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          selectedType = type;
                        });
                        applyFilters();
                      },
                      selectedColor: const Color(0xFF4F46E5),
                      labelStyle: TextStyle(
                        color: isSelected 
                            ? Colors.white 
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Date and City filters
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Date filter
                  Flexible(
                    flex: selectedDate != null ? 3 : 2,
                    child: OutlinedButton.icon(
                      onPressed: showDatePickerDialog,
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        selectedDate ?? 'Date',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  
                  if (selectedDate != null) ...[
                    IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        setState(() {
                          selectedDate = null;
                        });
                        applyFilters();
                      },
                    ),
                  ],
                  
                  const SizedBox(width: 8),
                  
                  // City filter
                  Flexible(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: selectedCity,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        isDense: true,
                      ),
                      hint: const Text('City', style: TextStyle(fontSize: 12)),
                      isExpanded: true,
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Cities', style: TextStyle(fontSize: 12)),
                        ),
                        ...cities.map((city) {
                          return DropdownMenuItem(
                            value: city,
                            child: Text(city, style: const TextStyle(fontSize: 12)),
                          );
                        }),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedCity = value;
                        });
                        applyFilters();
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '${filteredEvents.length} results found',
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            
            // Events list
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredEvents.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No events found',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredEvents.length,
                          itemBuilder: (context, index) {
                            Event event = filteredEvents[index];
                            
                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          EventDetailsScreen(event: event),
                                    ),
                                  ).then((_) => loadData());
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Event Image
                                    if (event.imageUrl != null) 
                                      ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(12),
                                          topRight: Radius.circular(12),
                                        ),
                                        child: Image.network(
                                          event.imageUrl!,
                                          height: 180,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            // Fallback if image fails to load
                                            return Container(
                                              height: 180,
                                              color: Colors.grey[300],
                                              child: const Icon(
                                                Icons.event,
                                                size: 64,
                                                color: Colors.grey,
                                              ),
                                            );
                                          },
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Container(
                                              height: 180,
                                              color: Colors.grey[200],
                                              child: Center(
                                                child: CircularProgressIndicator(
                                                  value: loadingProgress.expectedTotalBytes != null
                                                      ? loadingProgress.cumulativeBytesLoaded /
                                                          loadingProgress.expectedTotalBytes!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    
                                    // Event Details
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  event.title,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  event.isFavorite == 1
                                                      ? Icons.star
                                                      : Icons.star_border,
                                                  color: event.isFavorite == 1
                                                      ? Colors.amber
                                                      : Colors.grey,
                                                ),
                                                onPressed: () => toggleFavorite(event),
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 8),
                                          
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF4F46E5),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  event.type,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '\$${event.price.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF10B981),
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 8),
                                          
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                event.date,
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                              const SizedBox(width: 16),
                                              const Icon(
                                                Icons.location_on,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                event.city,
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          
                                          const SizedBox(height: 4),
                                          
                                          Row(
                                            children: [
                                              const Icon(
                                                Icons.place,
                                                size: 16,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                event.venue,
                                                style: const TextStyle(color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          
                                          // Show distance if available (Near Me filter)
                                          if (event.distanceFromUser != null) ...[
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.near_me,
                                                  size: 16,
                                                  color: Color(0xFF4F46E5),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  locationService.formatDistance(
                                                    event.distanceFromUser!
                                                  ),
                                                  style: const TextStyle(
                                                    color: Color(0xFF4F46E5),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}