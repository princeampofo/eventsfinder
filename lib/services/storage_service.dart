import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Service class for SharedPreferences operations
class StorageService {
  
  // Save logged in user ID
  Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('loggedInUserId', userId);
  }

  // Get logged in user ID
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('loggedInUserId');
  }

  // Save cached events
  Future<void> cacheEvents(List<Map<String, dynamic>> events) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(events);
    await prefs.setString('cachedEvents', jsonString);
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('loggedInUserId');
  }
}