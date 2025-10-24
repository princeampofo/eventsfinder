import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'main_screen.dart';
import '../services/storage_service.dart';

class SignupScreen extends StatefulWidget {
  final Function(bool) toggleTheme;
  
  const SignupScreen({super.key, required this.toggleTheme});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final DatabaseService dbService = DatabaseService();
  bool isLoading = false;

  final StorageService storageService = StorageService();

  // Signup button pressed
  void signupUser() async {
    String name = nameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    // Check if fields are empty
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Check if user already exists
    var existingUser = await dbService.getUserByEmail(email);
    
    if (existingUser != null) {
      setState(() {
        isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already registered')),
        );
      }
      return;
    }

    // Register new user
    await dbService.registerUser({
      'name': name,
      'email': email,
      'password': password,
    });

    setState(() {
      isLoading = false;
    });

    if (mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully!')),
      );
      
      // Navigate to main screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(toggleTheme: widget.toggleTheme)),
      );

      // set isLoggedIn to true
      await storageService.saveUserId(  
        await dbService.getUserByEmail(email).then((user) => user!.id!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme colors
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.primary),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo/icon
                Icon(
                  Icons.person_add,
                  size: 80,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 10),
                
                Text(
                  'Join us to discover amazing events',
                  style: TextStyle(
                    fontSize: 16,
                    color: colorScheme.onSurface.withValues(alpha:0.6),
                  ),
                ),
                const SizedBox(height: 40),
                
                // Name field
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
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
                
                // Signup button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : signupUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign Up',
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}