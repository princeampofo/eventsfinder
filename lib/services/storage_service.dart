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
  
  // Clear user session (logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('loggedInUserId');
  }

  // Save cached events
  Future<void> cacheEvents(List<Map<String, dynamic>> events) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(events);
    await prefs.setString('cachedEvents', jsonString);
  }

  // Get cached events
  Future<List<Map<String, dynamic>>> getCachedEvents() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('cachedEvents');
    
    if (jsonString == null) {
      return [];
    }
    
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<Map<String, dynamic>>();
  }


  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('loggedInUserId');
  }

  // Save favorite event IDs
  Future<void> saveFavorites(List<int> favoriteIds) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(favoriteIds);
    await prefs.setString('favoriteEvents', jsonString);
  }

  // Get favorite event IDs
  Future<List<int>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('favoriteEvents');
    
    if (jsonString == null) {
      return [];
    }
    
    List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.cast<int>();
  }

  // Save dark mode preference
  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  // Get dark mode preference
  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isDarkMode') ?? false;
  }
}