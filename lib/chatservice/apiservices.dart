import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:get/get.dart';

class ChatApiService {
  final String chatbaseUrl = 'http://localhost:5000';
  final String baseUrl = 'http://localhost:8081';

  String? _cachedChatJWT;
  final AuthService _authService = Get.find<AuthService>();

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
      final url = await http.post(Uri.parse('$baseUrl/chat/check'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': mainAuthToken
          },
          body: json.encode({'service': 'chat'}));
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
        print('\x1B[32m getAllRooms success: ${response.body}\x1B[0m');
        final Map<String, dynamic> data = json.decode(response.body);
        return data;
      } else {
        print(' getAllRooms failed: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load rooms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting rooms: $e');
    }
  }
}
