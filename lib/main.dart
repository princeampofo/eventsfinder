import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/login.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;
  final StorageService storageService = StorageService();

  @override
  void initState() {
    super.initState();
    loadThemePreference();
  }

  // Load saved theme preference
  void loadThemePreference() async {
    bool savedDarkMode = await storageService.getDarkMode();
    setState(() {
      isDarkMode = savedDarkMode;
    });
  }

  // Toggle theme
  void toggleTheme(bool isDark) {
    setState(() {
      isDarkMode = isDark;
    });
    storageService.setDarkMode(isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Events Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
          brightness: Brightness.dark,
        ),
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(toggleTheme: toggleTheme),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  final Function(bool) toggleTheme;

  const SplashScreen({super.key, required this.toggleTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final StorageService storageService = StorageService();

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  // Check if user is already logged in
  void checkLoginStatus() async {
    // Load theme preference first
    bool savedDarkMode = await storageService.getDarkMode();
    widget.toggleTheme(savedDarkMode);
    
    // Simulate loading delay
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if user is logged in
    bool isLoggedIn = await storageService.isLoggedIn();
    
    if (mounted) {
      if (isLoggedIn) {
        // Navigate to main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(toggleTheme: widget.toggleTheme),
          ),
        );
      } else {
        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginScreen(toggleTheme: widget.toggleTheme),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme colors
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                Icons.event,
                size: 80,
                color: colorScheme.primary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App name
            Text(
              'Local Events Finder',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimary,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Discover events near you',
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onPrimary.withValues(alpha: 0.8),
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            CircularProgressIndicator(
              color: colorScheme.onPrimary,
            ),
          ],
        ),
      ),
    );
  }
}