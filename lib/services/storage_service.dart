import 'package:shared_preferences/shared_preferences.dart';

// Service class for SharedPreferences operations
class StorageService {
  
  // Save logged in user ID
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loggedInUserId', userId);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('loggedInUserId');
  }
}