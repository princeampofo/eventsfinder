import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/storage_service.dart';
import '../models/user.dart';
import 'signup.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.toggleTheme});
  final Function(bool) toggleTheme;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers for text fields
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final DatabaseService dbService = DatabaseService();
  final StorageService storageService = StorageService();
  
  bool isLoading = false;

  // Login button pressed
  void loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Check if fields are empty
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Get user from database
    User? user = await dbService.getUserByEmail(email);

    setState(() {
      isLoading = false;
    });

    // Check if user exists and password matches
    if (user != null && user.password == password) {
      // Save user ID in SharedPreferences
      await storageService.saveUserId(user.id!);
      
      // Show success message
      if (mounted) {
        // Navigate to main screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen(toggleTheme: widget.toggleTheme)),
        );
      }
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon
                Icon(
                  Icons.event,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Local Events Finder',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                
                Text(
                  'Sign in to discover events',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha:0.6),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Email field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                
                // Password field
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                
                // Login button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Sign up link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SignupScreen(
                              toggleTheme: widget.toggleTheme,
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}