import 'package:flutter/material.dart';
import 'discover.dart';
import 'create_event.dart';
import 'tickets.dart';
import 'profile.dart';

class MainScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  
  const MainScreen({super.key, required this.toggleTheme});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 0;
  
  // List of screens for bottom navigation
  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      const DiscoverScreen(),
      const CreateEventScreen(),
      const TicketsScreen(),
      ProfileScreen(toggleTheme: widget.toggleTheme),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4F46E5),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.confirmation_number),
            label: 'Tickets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}