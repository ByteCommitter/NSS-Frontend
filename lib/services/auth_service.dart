import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Remove the problematic conditional import and use proper pattern
import 'dart:html' if (dart.library.io) 'package:mentalsustainability/services/mock_html.dart' as html_lib;

// Use a safe version of the Base64 extension
extension Base64Extension on String {
  String normalize() {
    String normalizedPayload = this;
    switch (normalizedPayload.length % 4) {
      case 1:
        normalizedPayload += '===';
        break;
      case 2:
        normalizedPayload += '==';
        break;
      case 3:
        normalizedPayload += '=';
        break;
    }
    return normalizedPayload;
  }
}

// Define API base URL that can be accessed throughout the app
class ApiConfig {
  // Base URL for API requests - different for various platforms
  static String get apiBase {
    if (kIsWeb) {
      // For web testing - check for production URL first
      const String prodUrl = String.fromEnvironment('WEB_API_URL');
      if (prodUrl.isNotEmpty) {
        return prodUrl;
      }
      return 'http://localhost:8081/';
    } else {
      // Check if we're in production/staging mode
      const String prodUrl = String.fromEnvironment('API_URL');
      if (prodUrl.isNotEmpty) {
        return prodUrl;
      }
      
      // For Android development - use your actual server IP or domain
      return 'http://10.0.2.2:8081/';  // For Android emulator
      // return 'http://192.168.1.100:8081/';  // For physical device (replace with your IP)
      // Deployment examples:
      // return 'https://your-ec2-instance.ap-south-1.compute.amazonaws.com/';  // AWS EC2
      // return 'https://your-backend.onrender.com/';  // Render
      // return 'https://your-backend.up.railway.app/';  // Railway
    }
  }
}

// Regex patterns for validation
class ValidationPatterns {
  // ID pattern for f20XXXXX format
  static final RegExp idPattern = RegExp(r'^f\d{2}[A-Z0-9]{6}$');
}

class AuthService extends GetxService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final RxBool isAuthenticated = false.obs;
  
  // Key for storing the JWT token
  static const String _tokenKey = 'jwt_token';

  // Additional fields to store user information
  final Rx<String?> _userId = Rx<String?>(null);
  final Rx<String?> _username = Rx<String?>(null);
  final Rx<bool> _isAdmin = Rx<bool>(false);
  final Rx<bool> _isVolunteer = Rx<bool>(false);
  final Rx<bool> _isWishVolunteer = Rx<bool>(false);
  final Rx<int> _points = Rx<int>(0);
  
  // Getters for the new fields
  String? get userId => _userId.value;
  String? get username => _username.value;
  bool get isAdmin => _isAdmin.value;
  bool get isVolunteer => _isVolunteer.value;
  bool get isWishVolunteer => _isWishVolunteer.value;
  int get points => _points.value;
  
  // Add this field to store the user ID
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
    // Initialize username - use the public method
    initUsername();
  }
  
  // FIXED: Make this method public by removing the underscore
  Future<void> initUsername() async {
    print('AuthService.initUsername() starting');
    final username = await getUsername();
    if (username != null) {
      print('AuthService.initUsername() found username: $username');
      _username.value = username;
      print('Username set in AuthService: $_username');
    } else {
      print('AuthService.initUsername() found no username');
    }
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
        _setWebLocalStorage(_tokenKey, token);
        print('Token stored in localStorage');
        
        // Backup in SharedPreferences
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
        // Use helper method
        final token = _getWebLocalStorage(_tokenKey);
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
  
  
  
  // Validate ID format (f20XXXXX) or allow "admin" for admin login
  bool isValidId(String id) {
    // Special case: allow "admin" as a valid ID for admin login
    if (id.toLowerCase() == 'admin') {
      return true;
    }
    // Regular validation for university IDs
    return ValidationPatterns.idPattern.hasMatch(id);
  }
  
  // Login method that communicates with your backend
  Future<Map<String, dynamic>?> login(String id, String password) async {
    try {
      print('Attempting login with ID: $id');
      
      // IMPORTANT: Clear all previous user data before login
      _userId.value = null;
      _username.value = null;
      _isAdmin.value = false;
      _isVolunteer.value = false;
      _isWishVolunteer.value = false;
      _points.value = 0;
      
      final ApiService apiService = Get.find<ApiService>();
      final response = await apiService.login(id, password);
      
      print('Raw login response from API: $response');
      
      // Backend login returns user data directly on success (no 'success' field)
      // Check if we have essential fields to determine success
      if (response != null && response.containsKey('token') && response.containsKey('user_id')) {
        print('Login successful for ID: $id');
        
        // Store token first
        final token = response['token'];
        if (token != null) {
          print('Storing token: ${token.length > 20 ? token.substring(0, 20) + "..." : token}');
          await storeToken(token);
          
          // Also store the token with the auth_token key for compatibility
          if (kIsWeb) {
            _setWebLocalStorage('auth_token', token);
          } else {
            await _secureStorage.write(key: 'auth_token', value: token);
          }
        } else {
          print('Warning: No token in successful login response');
        }
        
        // FIXED: Store user information in correct order
        // 1. Store user ID
        final newUserId = response['user_id'];
        if (newUserId != null) {
          _userId.value = newUserId;
          await storeUserId(newUserId);
          print('Setting and storing user ID to: $newUserId');
        }
        
        // 2. Store username - CRITICAL FIX
        final newUsername = response['username'];
        if (newUsername != null) {
          print('Storing new username: $newUsername');
          _username.value = newUsername;
          await _storeUsername(newUsername); // Store in persistent storage
          print('Username stored in memory and storage: $_username');
        } else {
          print('Warning: No username in login response');
        }
        
        // 3. Store other user properties
        _isAdmin.value = response['isAdmin'] ?? false;
        _isVolunteer.value = response['isVolunteer'] == 1;
        _isWishVolunteer.value = response['isWishVolunteer'] == 1;
        _points.value = response['points'] ?? 0;
        
        // Update admin status in isAdminUser
        isAdminUser.value = _isAdmin.value;
        await _storeAdminStatus(_isAdmin.value);
        
        // IMPORTANT: Set authenticated state LAST
        isAuthenticated.value = true;
        
        print('Login complete - Auth: ${isAuthenticated.value}, Username: ${_username.value}, Admin: ${isAdminUser.value}');
        
        return response;
      } else {
        print('Login failed: ${response?.toString() ?? 'null response'}');
        isAuthenticated.value = false;
        return null;
      }
    } catch (e) {
      print('Login error: $e');
      isAuthenticated.value = false;
      return null;
    }
  }

  // Add method to store username
  Future<void> _storeUsername(String username) async {
    try {
      if (kIsWeb) {
        _setWebLocalStorage('username', username);
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('username', username);
        } catch (e) {
          print('SharedPreferences username storage failed: $e');
        }
      } else {
        await _secureStorage.write(key: 'username', value: username);
      }
      print('Username stored: $username');
    } catch (e) {
      print('Error storing username: $e');
    }
  }

  // Enhanced method to get username with better debugging
  Future<String?> getUsername() async {
    try {
      print('AuthService.getUsername() called');
      
      // 1. Try memory cache first
      if (_username.value != null && _username.value!.isNotEmpty) {
        print('Using cached username: ${_username.value}');
        return _username.value;
      }
      print('No cached username, checking storage');
      
      // 2. Try storage
      String? storedUsername;
      if (kIsWeb) {
        // First try localStorage
        storedUsername = _getWebLocalStorage('username');
        print('Username from localStorage: $storedUsername');
        
        if (storedUsername != null && storedUsername.isNotEmpty) {
          _username.value = storedUsername; // Cache it
          return storedUsername;
        }
        
        // Fallback to SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          storedUsername = prefs.getString('username');
          print('Username from SharedPreferences: $storedUsername');
          
          if (storedUsername != null && storedUsername.isNotEmpty) {
            _username.value = storedUsername; // Cache it
            return storedUsername;
          }
        } catch (e) {
          print('SharedPreferences username retrieval failed: $e');
        }
      } else {
        // For mobile, use secure storage
        storedUsername = await _secureStorage.read(key: 'username');
        print('Username from secure storage: $storedUsername');
        
        if (storedUsername != null && storedUsername.isNotEmpty) {
          _username.value = storedUsername; // Cache it
          return storedUsername;
        }
      }
      
      // 3. Fallback to using ID if we couldn't find a username
      print('No username found, falling back to user ID: ${_userId.value}');
      return _userId.value;
    } catch (e) {
      print('Error getting username: $e');
      return _userId.value; // Fallback to ID if we encounter an error
    }
  }
  
  // Clear JWT token (logout) - handles web vs mobile platforms
  Future<void> clearToken() async {
    try {
      if (kIsWeb) {
        // Clear from localStorage directly
        html_lib.window.localStorage.remove(_tokenKey);
        
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
  
  // Logout method
  Future<void> logout() async {
    try {
      // Clear token
      await clearToken();
      // Clear user ID
      await clearUserId();
      // Clear admin status
      await _clearAdminStatus();
      // FIXED: Clear username from storage
      await _clearUsername();
      
      // Reset observables
      isAuthenticated.value = false;
      isAdminUser.value = false;
      _adminStatus = null;
      
      // Reset user data
      _userId.value = null;
      _username.value = null;
      _isAdmin.value = false;
      _isVolunteer.value = false;
      _isWishVolunteer.value = false;
      _points.value = 0;
      
      print('Logout complete - all data cleared including username');
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }

  // FIXED: Add method to clear username from storage
  Future<void> _clearUsername() async {
    try {
      // Clear from memory
      _username.value = null;
      
      if (kIsWeb) {
        // Clear from localStorage
        _removeWebLocalStorage('username');
        
        // Also clear from SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('username');
        } catch (e) {
          print('SharedPreferences username clear failed: $e');
        }
      } else {
        // For mobile, clear from secure storage
        await _secureStorage.delete(key: 'username');
      }
      print('Username cleared from all storage locations');
    } catch (e) {
      print('Error clearing username: $e');
    }
  }

  // Enhanced admin status initialization
  Future<void> initAdminStatus() async {
    try {
      // First try to get stored admin status
      final storedAdminStatus = await _getStoredAdminStatus();
      if (storedAdminStatus != null) {
        isAdminUser.value = storedAdminStatus;
        _adminStatus = storedAdminStatus ? 'admin' : 'user';
        print('Admin status from storage: ${isAdminUser.value}');
        return;
      }
      
      // Fallback: try to decode from JWT
      final token = await getToken();
      if (token != null) {
        final isAdmin = await _checkAdminStatusFromToken(token);
        isAdminUser.value = isAdmin;
        _adminStatus = isAdmin ? 'admin' : 'user';
        
        // Store the decoded status for future use
        await _storeAdminStatus(isAdmin);
        
        print('Admin status from JWT: ${isAdminUser.value}');
      }
    } catch (e) {
      print('Error initializing admin status: $e');
      isAdminUser.value = false;
      _adminStatus = 'user';
    }
  }
  
  // Get stored admin status
  Future<bool?> _getStoredAdminStatus() async {
    try {
      String? adminStatus;
      
      if (kIsWeb) {
        adminStatus = html_lib.window.localStorage['isAdmin'];
        if (adminStatus == null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            adminStatus = prefs.getString('isAdmin');
          } catch (e) {
            print('SharedPreferences admin status retrieval failed: $e');
          }
        }
      } else {
        adminStatus = await _secureStorage.read(key: 'isAdmin');
      }
      
      if (adminStatus != null) {
        return adminStatus == 'true';
      }
      
      return null;
    } catch (e) {
      print('Error getting stored admin status: $e');
      return null;
    }
  }
  
  // Method to decode JWT and check admin status (keep as fallback)
  Future<bool> _checkAdminStatusFromToken(String token) async {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final payload = parts[1];
      final normalizedPayload = payload.normalize();
      
      final bytes = base64Url.decode(normalizedPayload);
      final payloadString = utf8.decode(bytes);
      final payloadMap = json.decode(payloadString);
      
      // Check for admin status in the JWT payload
      final isAdmin = payloadMap['isAdmin'] == true || 
                     payloadMap['isAdmin'] == 1 ||
                     payloadMap['role'] == 'admin' || 
                     payloadMap['admin'] == true ||
                     payloadMap['user_type'] == 'admin';
      
      print('JWT payload admin check: $isAdmin');
      print('Full JWT payload: $payloadMap');
      
      return isAdmin;
    } catch (e) {
      print('Error decoding JWT for admin status: $e');
      return false;
    }
  }
  
  // // Clear all data (for complete logout)
  // Future<void> logout() async {
  //   try {
  //     // Clear token
  //     await clearToken();
  //     // Clear user ID
  //     await clearUserId();
  //     // Clear admin status
  //     await _clearAdminStatus();
      
  //     // Reset observables
  //     isAuthenticated.value = false;
  //     isAdminUser.value = false;
  //     _adminStatus = null;
      
  //     // Reset user data
  //     _userId.value = null;
  //     _username.value = null;
  //     _isAdmin.value = false;
  //     _isVolunteer.value = false;
  //     _isWishVolunteer.value = false;
  //     _points.value = 0;
      
  //     print('Logout complete - all data cleared');
  //   } catch (e) {
  //     print('Error during logout: $e');
  //     rethrow;
  //   }
  // }
  
  // Clear admin status
  Future<void> _clearAdminStatus() async {
    try {
      if (kIsWeb) {
        _removeWebLocalStorage('isAdmin');
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove('isAdmin');
        } catch (e) {
          print('SharedPreferences admin status clear failed: $e');
        }
      } else {
        await _secureStorage.delete(key: 'isAdmin');
      }
      print('Admin status cleared');
    } catch (e) {
      print('Error clearing admin status: $e');
    }
  }
  
  // Store user ID securely
  Future<void> storeUserId(String userId) async {
    try {
      // Store in memory
      _userId.value = userId;
      
      if (kIsWeb) {
        // Store in localStorage for web
        html_lib.window.localStorage['user_id'] = userId;
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
      if (_userId.value != null && _userId.value!.isNotEmpty) {
        print('Using cached user ID: $_userId');
        return _userId.value;
      }
      
      // 2. Try storage
      String? storedId;
      if (kIsWeb) {
        // First try localStorage
        storedId = html_lib.window.localStorage['user_id'];
        if (storedId != null && storedId.isNotEmpty) {
          _userId.value = storedId; // Cache it
          print('Retrieved user ID from localStorage: $storedId');
          return storedId;
        }
        
        // Fallback to SharedPreferences
        try {
          final prefs = await SharedPreferences.getInstance();
          storedId = prefs.getString('user_id');
          if (storedId != null && storedId.isNotEmpty) {
            _userId.value = storedId; // Cache it
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
          _userId.value = storedId; // Cache it
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
              _userId.value = tokenId.toString(); // Cache it
              // Also store it for future use
              await storeUserId(_userId.value!);
              print('Extracted user ID from token: $_userId');
              return _userId.value;
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
      _userId.value = null;
      
      if (kIsWeb) {
        // Clear from localStorage
        html_lib.window.localStorage.remove('user_id');
        
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
  
  // New OTP-based registration method (step 1: send OTP)
  Future<Map<String, dynamic>?> registerWithOTP(String universityId, String username, String password) async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.registerWithOTP(universityId, username, password);
      
      print('AuthService registerWithOTP response: $response');
      return response;
    } catch (e) {
      print('AuthService registerWithOTP error: $e');
      return null;
    }
  }

  // Resend OTP for registration
  Future<Map<String, dynamic>?> resendOTP(String universityId) async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.resendOTP(universityId);
      
      print('AuthService resendOTP response: $response');
      return response;
    } catch (e) {
      print('AuthService resendOTP error: $e');
      return null;
    }
  }

  // Verify OTP and complete registration (step 2: verify OTP)
  Future<Map<String, dynamic>?> verifyUserOTP(String universityId, int otpValue) async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.verifyUser(universityId, otpValue);
      
      print('AuthService verifyUserOTP response: $response');
      
      // If verification is successful and we get a token, store it
      if (response != null && response['success'] == true) {
        final token = response['token'];
        if (token != null) {
          await storeToken(token);
          
          // Store user ID
          final userId = response['user_id']?.toString() ?? universityId;
          await storeUserId(userId);
          
          // Store username if provided
          final username = response['username']?.toString();
          if (username != null) {
            await _storeUsername(username);
            _username.value = username;
          }
          
          // Set authentication status
          isAuthenticated.value = true;
          
          // Check for admin status
          final isAdminFromResponse = response['isAdmin'];
          if (isAdminFromResponse != null) {
            isAdminUser.value = isAdminFromResponse == true;
            _adminStatus = isAdminFromResponse == true ? 'admin' : 'user';
            await _storeAdminStatus(isAdminFromResponse == true);
          }
        }
      }
      
      return response;
    } catch (e) {
      print('AuthService verifyUserOTP error: $e');
      return null;
    }
  }

  // Forgot password (step 1: send OTP to email)
  Future<Map<String, dynamic>?> forgotPassword(String universityId) async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.forgotPassword(universityId);
      
      print('AuthService forgotPassword response: $response');
      return response;
    } catch (e) {
      print('AuthService forgotPassword error: $e');
      return null;
    }
  }

  // Reset password with OTP (step 2: verify OTP and set new password)
  Future<Map<String, dynamic>?> resetPassword(String universityId, int otpValue, String newPassword) async {
    try {
      final apiService = Get.find<ApiService>();
      final response = await apiService.resetPassword(universityId, otpValue, newPassword);
      
      print('AuthService resetPassword response: $response');
      return response;
    } catch (e) {
      print('AuthService resetPassword error: $e');
      return null;
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
  
  // Web localStorage helper methods that safely access localStorage on web only
  void _setWebLocalStorage(String key, String value) {
    if (kIsWeb) {
      try {
        html_lib.window.localStorage[key] = value;
      } catch (e) {
        print('Error accessing localStorage: $e');
        // Fallback to in-memory storage
        _inMemoryStorage[key] = value;
      }
    }
  }
  
  String? _getWebLocalStorage(String key) {
    if (kIsWeb) {
      try {
        return html_lib.window.localStorage[key];
      } catch (e) {
        print('Error reading from localStorage: $e');
        // Fallback to in-memory storage
        return _inMemoryStorage[key];
      }
    }
    return null;
  }
  
  void _removeWebLocalStorage(String key) {
    if (kIsWeb) {
      try {
        html_lib.window.localStorage.remove(key);
      } catch (e) {
        print('Error removing from localStorage: $e');
        // Fallback to in-memory storage
        _inMemoryStorage.remove(key);
      }
    }
  }
  
  // Add in-memory fallback storage for web platform
  final Map<String, String> _inMemoryStorage = {};
  
  // Fix: Add updatePoints method
  void updatePoints(int newPoints) {
    _points.value = newPoints;
  }
  
  // Fix: Rename second isAdmin method to avoid duplication
  Future<bool> checkAdminStatus() async {
    // First check if we have a cached value
    if (_adminStatus != null) {
      return _adminStatus == 'admin';
    }
    
    // Otherwise read from storage
    try {
      String? adminStatus;
      
      if (kIsWeb) {
        adminStatus = html_lib.window.localStorage['isAdmin'];
        if (adminStatus == null) {
          try {
            final prefs = await SharedPreferences.getInstance();
            adminStatus = prefs.getString('isAdmin');
          } catch (e) {
            print('SharedPreferences admin status retrieval failed: $e');
          }
        }
      } else {
        adminStatus = await _secureStorage.read(key: 'isAdmin');
      }
      
      // Cache the result for future sync checks
      _adminStatus = adminStatus == 'true' ? 'admin' : 'user';
      
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
        return _adminStatus == 'admin';
      }
      
      // For web, check localStorage
      if (kIsWeb) {
        final adminStatus = html_lib.window.localStorage['isAdmin'];
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
  
  // Add a method to refresh user status after changes - UPDATED FOR NEW API
  Future<void> refreshUserStatus() async {
    try {
      final userId = await getUserId();
      if (userId != null) {
        final ApiService apiService = Get.find<ApiService>();
        
        // Call the new volunteerStatus endpoint
        final response = await apiService.getVolunteerStatus(userId);
        
        final int verificationStatus = response['verificationStatus'] ?? -1;
        
        // Update user status based on verificationStatus
        switch (verificationStatus) {
          case 1:  // Verified volunteer
            _isVolunteer.value = true;
            _isWishVolunteer.value = false;
            break;
          case 0:  // Applied but not yet verified
            _isVolunteer.value = false;
            _isWishVolunteer.value = true;
            break;
          case -1: // Normal user
          default:
            _isVolunteer.value = false;
            _isWishVolunteer.value = false;
            break;
        }
        
        print('User volunteer status refreshed: verificationStatus=$verificationStatus, Volunteer=${_isVolunteer.value}, WishVolunteer=${_isWishVolunteer.value}');
            }
    } catch (e) {
      print('Error refreshing user status: $e');
    }
  }
  
  // Method to update wish volunteer status
  void setWishVolunteerStatus(bool status) {
    _isWishVolunteer.value = status;
  }
  
  // FIXED: Add missing _storeAdminStatus method
  Future<void> _storeAdminStatus(bool isAdmin) async {
    try {
      final adminValue = isAdmin.toString();
      
      if (kIsWeb) {
        _setWebLocalStorage('isAdmin', adminValue);
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('isAdmin', adminValue);
        } catch (e) {
          print('SharedPreferences admin status storage failed: $e');
        }
      } else {
        await _secureStorage.write(key: 'isAdmin', value: adminValue);
      }
      print('Admin status stored: $isAdmin');
    } catch (e) {
      print('Error storing admin status: $e');
    }
  }
}
