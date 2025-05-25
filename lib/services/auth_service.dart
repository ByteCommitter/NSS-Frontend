import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:html' as html; // Import for web localStorage

// Define API base URL that can be accessed throughout the app
class ApiConfig {
  // Base URL for API requests - different for various platforms
  static String get apiBase {
    if (kIsWeb) {
      // For web testing
      return 'http://localhost:8081/';
    } else {
      // For Android emulator use 10.0.2.2 instead of localhost
      // For iOS simulator use 127.0.0.1
      // For physical devices, use your computer's IP address on the same network
      return 'http://10.0.2.2:8081/'; // Use this for Android emulator
      // return 'http://127.0.0.1:8081/'; // Use this for iOS simulator
      // return 'http://YOUR_COMPUTER_IP:8081/'; // Use this for physical devices
    }
  }
}

// Regex patterns for validation
class ValidationPatterns {
  // ID pattern for f20XXXXX format
  static final RegExp idPattern = RegExp(r'^f\d{2}[A-Z0-9]{6}$');
}

class AuthService extends GetxController {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final RxBool isAuthenticated = false.obs;
  
  // Key for storing the JWT token
  static const String _tokenKey = 'jwt_token';

  // Add this field to store the user ID
  String? _userId;
  
  // Add this variable to cache the admin status for synchronous checks
  String? _adminStatus;
  
  // Create an observable for admin status
  final RxBool isAdminUser = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Check for existing token when app starts
    checkAndSetAuthStatus();
    // Also initialize admin status
    initAdminStatus();
  }
  
  // Initialize auth status from stored token
  Future<void> checkAndSetAuthStatus() async {
    try {
      final token = await getToken();
      isAuthenticated.value = token != null && token.isNotEmpty;
      print('Auth status initialized: ${isAuthenticated.value}');
      
      if (isAuthenticated.value) {
        // Verify token validity with backend (optional)
        // await verifyToken();
      }
    } catch (e) {
      print('Error checking auth status: $e');
      isAuthenticated.value = false;
    }
  }
  
  // Store JWT token securely - handles web vs mobile platforms
  Future<void> storeToken(String token) async {
    try {
      if (kIsWeb) {
        // Direct localStorage access for web - most reliable method
        html.window.localStorage[_tokenKey] = token;
        print('Token stored in localStorage');
        
        // Backup in SharedPreferences (attempt)
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
        } catch (e) {
          print('SharedPreferences backup failed: $e');
        }
      } else {
        // For mobile, use secure storage
        await _secureStorage.write(key: _tokenKey, value: token);
      }
      isAuthenticated.value = true;
      print('Token stored successfully');
    } catch (e) {
      print('Error storing token: $e');
    }
  }
  
  // Get JWT token - handles web vs mobile platforms
  Future<String?> getToken() async {
    try {
      if (kIsWeb) {
        // First try localStorage directly
        final token = html.window.localStorage[_tokenKey];
        if (token != null && token.isNotEmpty) {
          return token;
        }
        
        // Fallback to SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          return prefs.getString(_tokenKey);
        } catch (e) {
          print('SharedPreferences retrieval failed: $e');
          return null;
        }
      } else {
        // For mobile, use secure storage
        return await _secureStorage.read(key: _tokenKey);
      }
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }
  
  // Clear JWT token (logout) - handles web vs mobile platforms
  Future<void> clearToken() async {
    try {
      if (kIsWeb) {
        // Clear from localStorage directly
        html.window.localStorage.remove(_tokenKey);
        
        // Also clear from SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove(_tokenKey);
        } catch (e) {
          print('SharedPreferences clear failed: $e');
        }
      } else {
        // For mobile, clear from secure storage
        await _secureStorage.delete(key: _tokenKey);
      }
      isAuthenticated.value = false;
      print('Token cleared successfully');
    } catch (e) {
      print('Error clearing token: $e');
    }
  }
  
  // Validate ID format (f20XXXXX)
  bool isValidId(String id) {
    return ValidationPatterns.idPattern.hasMatch(id);
  }
  
  // Login method that communicates with your backend
  Future<bool> login(String username, String password) async {
    // Validate ID format
    if (!isValidId(username)) {
      print('Invalid ID format. Expected format: f20XXXXX');
      return false;
    }
    
    try {
      // Connect to localhost:8081 auth/login endpoint
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBase}auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': username, // Changed from 'username' to match backend
          'password': password,
        }),
      );
      
      // Print response for debugging
      print('Login response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        
        if (token != null) {
          await storeToken(token);
          
          // Extract user ID from token or use the provided username
          String userIdToStore = username;
          bool isAdmin = false; // Default to not admin
          
          // Try to get user ID and admin status from token payload
          try {
            final parts = token.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              final normalized = base64Url.normalize(payload);
              final decoded = utf8.decode(base64Url.decode(normalized));
              final Map<String, dynamic> data = json.decode(decoded);
              
              if (data.containsKey('id')) {
                userIdToStore = data['id'].toString();
                print('Extracted user ID from token: $userIdToStore');
              }
              
              // Extract admin status from token claims
              if (data.containsKey('isAdmin')) {
                isAdmin = data['isAdmin'] == true;
                print('Extracted admin status from token: $isAdmin');
              } else if (data.containsKey('role')) {
                isAdmin = data['role'] == 'admin';
                print('Extracted admin role from token: $isAdmin');
              }
              
              // Store the admin status
              await _secureStorage.write(key: 'isAdmin', value: isAdmin.toString());
              print('Stored admin status: $isAdmin');
            }
          } catch (e) {
            print('Error extracting data from token: $e');
          }
          
          // Store the user ID
          await storeUserId(userIdToStore);
          print('Stored user ID: $userIdToStore');
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }
  
  // Store user ID securely
  Future<void> storeUserId(String userId) async {
    try {
      // Store in memory
      _userId = userId;
      
      if (kIsWeb) {
        // Store in localStorage for web
        html.window.localStorage['user_id'] = userId;
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId);
        } catch (e) {
          print('SharedPreferences user ID storage failed: $e');
        }
      } else {
        // For mobile, use secure storage
        await _secureStorage.write(key: 'user_id', value: userId);
      }
      print('User ID stored successfully: $userId');
    } catch (e) {
      print('Error storing user ID: $e');
    }
  }
  
  // Get user ID - combined implementation
  Future<String?> getUserId() async {
    try {
      // 1. Try memory cache first (fastest)
      if (_userId != null && _userId!.isNotEmpty) {
        print('Using cached user ID: $_userId');
        return _userId;
      }
      
      // 2. Try storage
      String? storedId;
      if (kIsWeb) {
        // First try localStorage
        storedId = html.window.localStorage['user_id'];
        if (storedId != null && storedId.isNotEmpty) {
          _userId = storedId; // Cache it
          print('Retrieved user ID from localStorage: $storedId');
          return storedId;
        }
        
        // Fallback to SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          storedId = prefs.getString('user_id');
          if (storedId != null && storedId.isNotEmpty) {
            _userId = storedId; // Cache it
            print('Retrieved user ID from SharedPreferences: $storedId');
            return storedId;
          }
        } catch (e) {
          print('SharedPreferences user ID retrieval failed: $e');
        }
      } else {
        // For mobile, use secure storage
        storedId = await _secureStorage.read(key: 'user_id');
        if (storedId != null && storedId.isNotEmpty) {
          _userId = storedId; // Cache it
          print('Retrieved user ID from secure storage: $storedId');
          return storedId;
        }
      }
      
      // 3. Try to extract from token as last resort
      final token = await getToken();
      if (token != null) {
        try {
          final parts = token.split('.');
          if (parts.length == 3) {
            final payload = parts[1];
            final normalized = base64Url.normalize(payload);
            final decoded = utf8.decode(base64Url.decode(normalized));
            final Map<String, dynamic> data = json.decode(decoded);
            
            // Usually the user ID is stored in the 'sub' or 'id' field
            final tokenId = data['id'] ?? data['sub'];
            if (tokenId != null) {
              _userId = tokenId.toString(); // Cache it
              // Also store it for future use
              await storeUserId(_userId!);
              print('Extracted user ID from token: $_userId');
              return _userId;
            }
          }
        } catch (e) {
          print('Error decoding JWT: $e');
        }
      }
      
      print('Could not retrieve user ID from any source');
      return null;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }
  
  // Clear stored user ID (for logout)
  Future<void> clearUserId() async {
    try {
      // Clear from memory
      _userId = null;
      
      if (kIsWeb) {
        // Clear from localStorage
        html.window.localStorage.remove('user_id');
        
        // Also clear from SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('user_id');
        } catch (e) {
          print('SharedPreferences user ID clear failed: $e');
        }
      } else {
        // For mobile, clear from secure storage
        await _secureStorage.delete(key: 'user_id');
      }
      print('User ID cleared successfully');
    } catch (e) {
      print('Error clearing user ID: $e');
    }
  }
  
  // Clear all data (for complete logout)
  Future<void> logout() async {
    try {
      // Clear token
      await clearToken();
      // Clear user ID
      await clearUserId();
      
      print('Logout complete - all data cleared');
    } catch (e) {
      print('Error during logout: $e');
      rethrow; // Re-throw for handling upstream
    }
  }
  
  // Signup method that communicates with your backend
  Future<bool> signup(String id, String username, String password) async {
    // Validate ID format
    if (!isValidId(id)) {
      print('Invalid ID format. Expected format: f20XXXXXX');
      return false;
    }
    
    try {
      print('Attempting to connect to: ${ApiConfig.apiBase}auth/register');
      
      // Connect to localhost:8081 auth/register endpoint
      final response = await http.post(
        Uri.parse('${ApiConfig.apiBase}auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'university_id': id,
          'username': username, 
          'password': password
        }),
      );
      
      // Print response for debugging
      print('Signup response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Store the token from signup response so user is automatically logged in
        final responseData = json.decode(response.body);
        final token = responseData['token'];
        
        if (token != null) {
          await storeToken(token);
          // Store the user ID
          await storeUserId(id); // Store university ID as user ID
          return true;
        }
        return true; // Still return true even if token isn't present
      }
      return false;
    } catch (e) {
      print('Signup error: $e');
      // More detailed error logging
      print('Error details: ${e.toString()}');
      return false;
    }
  }
  
  // Get auth headers for API requests
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  
  // Add a method to verify token with backend (optional)
  Future<bool> verifyToken() async {
    try {
      final token = await getToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      
      // TODO: Implement backend verification if needed
      // final response = await http.get(
      //   Uri.parse('${ApiConfig.apiBase}auth/verify'),
      //   headers: await getAuthHeaders(),
      // );
      
      // if (response.statusCode == 200) {
      //   return true;
      // } else {
      //   await clearToken();
      //   return false;
      // }
      
      return true; // Assume token is valid if it exists
    } catch (e) {
      print('Token verification error: $e');
      return false;
    }
  }
  
  // Check if the current user is an admin
  Future<bool> isAdmin() async {
    // First check if we have a cached value
    if (_adminStatus != null) {
      return _adminStatus == 'true';
    }
    
    // Otherwise read from storage
    try {
      final token = await _secureStorage.read(key: 'jwt_token');
      if (token == null || token.isEmpty) return false;
      
      String? adminStatus;
      if (kIsWeb) {
        adminStatus = html.window.localStorage['isAdmin'];
      } else {
        adminStatus = await _secureStorage.read(key: 'isAdmin');
      }
      
      // Cache the result for future sync checks
      _adminStatus = adminStatus;
      
      // Update the observable
      isAdminUser.value = adminStatus == 'true';
      
      return adminStatus == 'true';
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }
  
  // Update the isAdminSync method for middleware
  bool isAdminSync() {
    try {
      // Check if the user is logged in first
      if (!isAuthenticated.value) {
        return false;
      }
      
      // Use cached admin status from memory first
      if (_adminStatus != null) {
        return _adminStatus == 'true';
      }
      
      // For web, check localStorage
      if (kIsWeb) {
        final adminStatus = html.window.localStorage['isAdmin'];
        return adminStatus == 'true';
      } else {
        // For mobile, we can't use _secureStorage.read() directly as it's async
        // Just return false if we don't have cached status yet
        return false; // Safe default when we can't check synchronously
      }
    } catch (e) {
      print('Error checking admin status: $e');
      return false;
    }
  }

  // Add this method to initialize admin status from storage when app starts
  Future<void> initAdminStatus() async {
    try {
      String? adminStatus;
      
      if (kIsWeb) {
        adminStatus = html.window.localStorage['isAdmin'];
      } else {
        adminStatus = await _secureStorage.read(key: 'isAdmin');
      }
      
      // Cache the admin status for sync checks
      _adminStatus = adminStatus;
      
      // Update the observable
      isAdminUser.value = adminStatus == 'true';
      print('Admin status initialized: ${isAdminUser.value}');
    } catch (e) {
      print('Error initializing admin status: $e');
      _adminStatus = 'false';
      isAdminUser.value = false;
    }
  }
}
