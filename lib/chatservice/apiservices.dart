import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:get/get.dart';

import 'package:flutter/foundation.dart';

class ApiConfig {
  // Replace this with your actual laptop IP address
  static const String _laptopIP = '172.19.80.1';

  // Base URLs
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8081';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'http://$_laptopIP:8081'; // Mobile uses laptop IP
    } else {
      return 'http://localhost:8081'; // Desktop development
    }
  }

  static String get chatbaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000';
    } else if (Platform.isAndroid || Platform.isIOS) {
      return 'http://$_laptopIP:5000'; // Mobile uses laptop IP
    } else {
      return 'http://localhost:5000'; // Desktop development
    }
  }

  // Debug info
  static Map<String, dynamic> getDebugInfo() {
    return {
      'platform': kIsWeb ? 'web' : Platform.operatingSystem,
      'baseUrl': baseUrl,
      'chatbaseUrl': chatbaseUrl,
      'laptopIP': _laptopIP,
    };
  }
}

class ChatApiService {
  String get chatbaseUrl => ApiConfig.chatbaseUrl;
  String get baseUrl => ApiConfig.baseUrl;
  String? _cachedChatJWT;
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true; // invalid token
      final payload = json
          .decode(utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
      final exp = payload['exp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return now >= exp; // true if expired
    } catch (_) {
      return true; // if decoding fails, treat as expired
    }
  }

  Future<String> getChatJWT() async {
    if ((_cachedChatJWT != null) && !_isTokenExpired(_cachedChatJWT!)) {
      return _cachedChatJWT!;
    }
    try {
      final mainAuthToken = await _authService.getToken();

      if (mainAuthToken == null) {
        throw Exception('User not authenticated - Main Token not found');
      }

      final url = await http
          .post(Uri.parse('$baseUrl/chat/check'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': mainAuthToken
              },
              body: json.encode({"chatToken": ""}))
          .timeout(const Duration(seconds: 10));

      if (url.statusCode == 200) {
        final data = json.decode(url.body);
        _cachedChatJWT = data["token"];

        return _cachedChatJWT!;
      } else {
        throw Exception('Failed to get a chat token: ${url.statusCode}');
      }
    } catch (e) {
      throw Exception("Error geting JWT : $e");
    }
  }

  Future<Map<String, dynamic>> getAllRooms() async {
    try {
      final chatJWT = await getChatJWT();
      final response = await http.get(
        Uri.parse('$chatbaseUrl/chat/message/sessions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': chatJWT,
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load rooms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting rooms: $e');
    }
  }

  Future<Map<String, dynamic>> getRoomMessages(String sessionid) async {
    final chatJWT = await getChatJWT();
    final response = await http.get(
        Uri.parse('$chatbaseUrl/chat/message/$sessionid'),
        headers: {'Authorization': chatJWT});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to get Messages: ${response.statusCode}');
    }
  }

  Future<bool> sendText(String text, String sessionID) async {
    try {
      final chatJWT = await getChatJWT();
      final response = await http.post(
          Uri.parse("$chatbaseUrl/chat/message/$sessionID"),
          headers: {
            "Authorization": chatJWT,
            "Content-Type": "application/json"
          },
          body: json.encode({"message": text}));

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> createRoom(
      Map<String, dynamic> groupData) async {
    final maintoken = await _authService.getToken();
    if (maintoken == null) {
      throw Exception('User not authenticated - Main Token not found');
    }
    try {
      final response = await http.post(
        Uri.parse(
            '$baseUrl/chat/createSession'), // Replace with your actual endpoint
        headers: {
          "Authorization": maintoken,
          'Content-Type': 'application/json',
          // Add any authentication headers if needed
        },
        body: json.encode(groupData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>> groupinfo(String sessionID) async {
    final chatJWT = await getChatJWT();
    try {
      final response = await http.get(
          Uri.parse("$chatbaseUrl/chat/message/members/$sessionID"),
          headers: {"Authorization": chatJWT});
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final participants = data['participants'] as List;
        return data;
      } else {
        throw Exception(
            "Error getting the desired list ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(e);
    }
  }
}
