import 'package:flutter/material.dart';
import 'services/storage_service.dart';
import 'screens/login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Local Events Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4F46E5),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// Splash Screen
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
    // Wait for 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    // Check if user is logged in
    bool isLoggedIn = await storageService.isLoggedIn();
    
    if (mounted) {
      if (isLoggedIn) {
        // Navigate to main screen( to be implemented)
        debugPrint('User is already logged in');
        
      } else {
        // Navigate to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4F46E5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.event,
                size: 80,
                color: Color(0xFF4F46E5),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // App name
            const Text(
              'Local Events Finder',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 16),
            
            const Text(
              'Discover events near you',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            
            const SizedBox(height: 48),
            
            // Loading indicator
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}