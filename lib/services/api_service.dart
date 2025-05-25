import 'dart:convert';
import 'dart:async'; // Added missing import for TimeoutException
import 'dart:math' as math; // lowercase math to follow convention
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:mentalsustainability/pages/Home/home_page.dart' hide Event; // Hide Event from home_page
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/models/admin_models.dart'; // Keep this import for Event

// Define a specific class for API events to avoid conflicts
class ApiEvent {
  final String id;
  final String title;
  final String description;
  final String date;
  final String fromTime;
  final String toTime;
  final String location;
  final String? imageUrl;

  ApiEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.location,
    this.imageUrl,
  });
}

class ApiService extends GetxService {
  static ApiService get to => Get.find();
  
  // Adjust baseUrl for web vs mobile
  String get baseUrl {
    if (kIsWeb) {
      // For web testing, use the full URL without localhost
      // This helps avoid CORS issues
      return 'http://localhost:8081/';
    } else {
      return 'http://10.0.2.2:8081/'; // Use this for Android emulator
      // return 'http://127.0.0.1:8081/'; // Use this for iOS simulator
    }
  }
  
  final AuthService _authService = Get.find<AuthService>();
  
  // Authentication APIs
  
  Future<Map<String, dynamic>?> register(String universityId, String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'university_id': universityId,
          'username': username,
          'password': password,
        }),
      );
      
      print('Register response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Register error: $e');
      return null;
    }
  }
  
  Future<Map<String, dynamic>?> login(String id, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${baseUrl}auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'password': password,
        }),
      );
      
      print('Login response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return null;
    } catch (e) {
      print('Login error: $e');
      return null;
    }
  }
  
  // Events APIs
  Future<List<ApiEvent>> getEvents() async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return [];
      }
      
      print('Fetching events from: ${baseUrl}events/');
      print('Token available: ${token.length > 20 ? "Yes (${token.substring(0, 20)}...)" : "Yes"}');
      
      final response = await http.get(
        Uri.parse('${baseUrl}events/'),
        headers: {
          'Authorization': token, // Sending token as-is as per API requirements
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );
      
      print('Get events response: ${response.statusCode}');
      print('Response headers: ${response.headers}');
      
      if (response.statusCode != 200) {
        print('Error response body: ${response.body}');
        return [];
      }
      
      // Debugging: print the raw response body
      print('Raw response body: ${response.body}');
      
      if (response.statusCode == 200) {
        // Try to parse as a map first if the response is an object with an events field
        try {
          final responseData = json.decode(response.body);
          List<dynamic> eventsData;
          
          if (responseData is Map && responseData.containsKey('events')) {
            eventsData = responseData['events'] as List<dynamic>;
            print('Found events array in response object');
          } else if (responseData is List) {
            eventsData = responseData;
            print('Response is directly an events array');
          } else {
            print('Unexpected response format: $responseData');
            return [];
          }
          
          print('Received ${eventsData.length} events from backend');
          
          final events = eventsData.map((eventJson) {
            print('Processing event: ${eventJson['id']} - ${eventJson['title']}');
            
            return ApiEvent(
              id: eventJson['id'].toString(),
              title: eventJson['title'] ?? 'Untitled Event',
              description: eventJson['description'] ?? 'No description available',
              date: eventJson['date'] ?? 'TBD',
              fromTime: eventJson['fromTime'] ?? '00:00:00',
              toTime: eventJson['ToTime'] ?? '00:00:00', // Note: API uses 'ToTime' with capital T
              location: eventJson['eventVenue'] ?? 'TBD',
              imageUrl: eventJson['banner_image'],
            );
          }).toList();
          
          print('Successfully parsed ${events.length} events');
          return events;
        } catch (parseError) {
          print('Error parsing events JSON: $parseError');
          // Try to show the raw response for debugging
          print('Raw response that failed to parse: ${response.body}');
          return [];
        }
      } else {
        print('Failed to load events: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception fetching events: $e');
      return [];
    }
  }
  
  Future<bool> createEvent(ApiEvent event) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      final response = await http.post(
        Uri.parse('${baseUrl}events/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'title': event.title,
          'description': event.description,
          'date': event.date,
          'fromTime': event.fromTime,
          'ToTime': event.toTime, // Note: API uses 'ToTime' with capital T
          'eventVenue': event.location,
          'banner_image': event.imageUrl,
        }),
      );
      
      print('Create event response: ${response.statusCode} - ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error creating event: $e');
      return false;
    }
  }
  
  Future<bool> registerForEvent(String userId, String eventId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available for registration');
        return false;
      }
      
      // Prepare request based on the exact format shown in the example
      final requestBody = {
        'user_id': userId,
        'event_id': eventId,
      };
      
      print('Registering user for event with: User ID=$userId, Event ID=$eventId');
      print('Full request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse('${baseUrl}events/user-event/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json'
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          print('Registration request timed out');
          throw TimeoutException('Request timed out');
        },
      );
      
      print('Registration response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      // Parse response to check for specific messages
      try {
        final responseData = json.decode(response.body);
        if (responseData['message'] != null) {
          // Check if the message indicates the user is already registered
          if (responseData['message'].toString().contains('already registered')) {
            print('User is already registered for this event');
            // Return false with a specific error code that can be checked
            throw AlreadyRegisteredException('User already registered for this event');
          }
        }
      } catch (e) {
        if (e is AlreadyRegisteredException) {
          rethrow; // Re-throw this specific exception
        }
        // Ignore other parsing errors
      }
      
      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Registration successful
      } else {
        print('Registration failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Exception during registration: $e');
      if (e is AlreadyRegisteredException) {
        rethrow; // Re-throw so we can handle it specifically in the UI
      }
      return false;
    }
  }
  
  // Get user's registered events - updated with the correct endpoint
  Future<List<ApiEvent>> getUserRegisteredEvents() async {
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();
      
      if (token == null || userId == null) {
        print('No auth token or user ID available');
        return [];
      }
      
      // Using the correct endpoint with query parameters as provided
      final response = await http.get(
        Uri.parse('${baseUrl}events/user-event?query=eventsForUser&user_id=$userId'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );
      
      print('Get user registered events response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          List<dynamic> eventsData;
          
          if (responseData is Map && responseData.containsKey('events')) {
            eventsData = responseData['events'] as List<dynamic>;
            print('Found events array in response object');
          } else if (responseData is List) {
            eventsData = responseData;
            print('Response is directly an events array');
          } else {
            print('Unexpected response format: $responseData');
            return [];
          }
          
          print('Received ${eventsData.length} registered events for user');
          
          final events = eventsData.map((eventJson) {
            return ApiEvent(
              id: eventJson['id'].toString(),
              title: eventJson['title'] ?? 'Unknown Event',
              description: eventJson['description'] ?? 'No description available',
              date: eventJson['date'] ?? 'TBD',
              fromTime: eventJson['fromTime'] ?? '00:00:00',
              toTime: eventJson['ToTime'] ?? '00:00:00',
              location: eventJson['eventVenue'] ?? 'TBD',
              imageUrl: eventJson['banner_image'],
            );
          }).toList();
          
          return events;
        } catch (e) {
          print('Error parsing user registered events: $e');
          return [];
        }
      } else {
        print('Failed to load user registered events: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching user registered events: $e');
      return [];
    }
  }

  // Check if user is registered for a specific event - simplified to use the list approach
  Future<bool> isUserRegisteredForEvent(String userId, String eventId) async {
    try {
      // Get all registered events and check if this event is among them
      final registeredEvents = await getUserRegisteredEvents();
      return registeredEvents.any((event) => event.id == eventId);
    } catch (e) {
      print('Error checking if user is registered: $e');
      return false;
    }
  }

  // Admin only function
  Future<bool> verifyEventParticipation(String userId, String eventId, bool participated) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      final response = await http.put(
        Uri.parse('${baseUrl}events/user-event/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'user_id': userId,
          'event_id': eventId,
          'isParticipated': participated ? 1 : 0,
        }),
      );
      
      print('Verify event participation response: ${response.statusCode} - ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying event participation: $e');
      return false;
    }
  }
  
  // Get user's registered events and participation status
  Future<List<EventParticipation>> getUserParticipations() async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return [];
      }
      
      // Using the correct endpoint format based on the other endpoints
      final response = await http.get(
        Uri.parse('${baseUrl}events/user-event/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );
      
      print('Get user participations response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final dynamic data = json.decode(response.body);
          List<dynamic> participationsData;
          
          if (data is Map && data.containsKey('participations')) {
            participationsData = data['participations'] as List<dynamic>;
          } else if (data is List) {
            participationsData = data;
          } else {
            print('Unexpected participations data format: $data');
            return [];
          }
          
          return participationsData.map((item) => EventParticipation(
            eventId: item['event_id']?.toString() ?? '',
            eventName: item['title'] ?? 'Unknown Event',
            pointsEarned: item['points'] != null ? int.tryParse(item['points'].toString()) ?? 0 : 0,
            date: item['date'] ?? 'Unknown Date',
          )).toList();
        } catch (e) {
          print('Error parsing user participations: $e');
          return [];
        }
      } else {
        print('Failed to load user participations: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Error fetching user participations: $e');
      return [];
    }
  }
  
  // Manual testing method to verify API connectivity
  Future<bool> testApiConnection() async {
    try {
      final response = await http.get(Uri.parse('${baseUrl}health'));
      print('API health check: ${response.statusCode} - ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API health check failed: $e');
      return false;
    }
  }
  
  // Method to handle partial JSON response
  List<Event> parseEventsFromPartialJson(String jsonStr) {
    try {
      // Try to clean up and fix the JSON if it's partial or malformed
      if (jsonStr.trim().startsWith('{')) {
        // It's an object
        final data = json.decode(jsonStr);
        if (data.containsKey('events') && data['events'] is List) {
          return (data['events'] as List).map((e) => Event(
            id: e['id'].toString(),
            title: e['title'] ?? 'Unknown',
            description: e['description'] ?? '',
            date: e['date'] ?? '',
            fromTime: e['fromTime'] ?? '',
            toTime: e['ToTime'] ?? '',
            location: e['eventVenue'] ?? '',
            imageUrl: e['banner_image'],
          )).toList();
        }
      } else if (jsonStr.trim().startsWith('[')) {
        // It's an array
        final List data = json.decode(jsonStr);
        return data.map((e) => Event(
          id: e['id'].toString(),
          title: e['title'] ?? 'Unknown',
          description: e['description'] ?? '',
          date: e['date'] ?? '',
          fromTime: e['fromTime'] ?? '',
          toTime: e['ToTime'] ?? '',
          location: e['eventVenue'] ?? '',
          imageUrl: e['banner_image'],
        )).toList();
      }
    } catch (e) {
      print('Error parsing partial JSON: $e');
    }
    return [];
  }
  
  // Create test events from the JSON snippet the user provided
  List<ApiEvent> getTestEvents() {
    return [
      ApiEvent(
        id: '1',
        title: 'New event',
        description: 'Description of event1',
        date: '2023-09-15',
        fromTime: '14:30:00',
        toTime: '16:30:00',
        location: 'IN our heads',
        imageUrl: null,
      ),
      ApiEvent(
        id: '2',
        title: 'New event 2',
        description: 'Another test event',
        date: '2023-09-20',
        fromTime: '10:00:00',
        toTime: '12:00:00',
        location: 'Test location',
        imageUrl: null,
      ),
    ];
  }
  
  // Admin methods for event management
  Future<List<AdminEvent>> getAdminEvents() async {
    try {
      // Implementation would call your backend API
      // For now, return sample data
      return [
        AdminEvent(
          id: 'e1',
          title: 'Tree Plantation Drive',
          description: 'Join us for a tree plantation drive to help the environment.',
          date: '12/06/2023',
          fromTime: '9:00',
          toTime: '12:00',
          location: 'City Park',
        ),
        AdminEvent(
          id: 'e2',
          title: 'Blood Donation Camp',
          description: 'Donate blood and save lives.',
          date: '20/06/2023',
          fromTime: '10:00',
          toTime: '16:00',
          location: 'Community Center',
        ),
      ];
    } catch (e) {
      print('Error getting admin events: $e');
      rethrow;
    }
  }

  Future<void> createAdminEvent(
    String title,
    String description,
    String date,
    String fromTime,
    String toTime,
    String location,
  ) async {
    // Implementation would call your backend API
    print('Creating admin event: $title');
  }

  Future<void> updateEvent(
    String id,
    String title,
    String description,
    String date,
    String fromTime,
    String toTime,
    String location,
  ) async {
    // Implementation would call your backend API
    print('Updating event: $id - $title');
  }

  Future<void> deleteEvent(String id) async {
    // Implementation would call your backend API
    print('Deleting event: $id');
  }

  // Admin methods for notification management
  Future<List<AdminUpdate>> getAdminUpdates() async {
    // Implementation would call your backend API
    // For now, return sample data
    return [
      AdminUpdate(
        id: 'n1',
        title: 'New Event Registration Open',
        message: 'Tree Plantation Drive registration is now open. Register before June 3rd.',
        time: '2 hours ago',
        isRead: false,
      ),
      AdminUpdate(
        id: 'n2',
        title: 'Reminder: NSS Meetup',
        message: 'Don\'t forget to attend the NSS Annual Meetup on June 12th.',
        time: '1 day ago',
        isRead: true,
      ),
    ];
  }

  Future<void> createNotification(String title, String message) async {
    // Implementation would call your backend API
    print('Creating notification: $title');
  }

  Future<void> updateNotification(String id, String title, String message) async {
    // Implementation would call your backend API
    print('Updating notification: $id - $title');
  }

  Future<void> deleteNotification(String id) async {
    // Implementation would call your backend API
    print('Deleting notification: $id');
  }

  // Admin methods for user management
  Future<List<AdminUser>> getAdminUsers() async {
    // Implementation would call your backend API
    // For now, return sample data
    return [
      AdminUser(id: 'u1', name: 'Rajesh Kumar', points: 780, rank: 1),
      AdminUser(id: 'u2', name: 'Priya Singh', points: 720, rank: 2),
      AdminUser(id: 'u3', name: 'Amit Sharma', points: 690, rank: 3),
    ];
  }
}

// Custom exception for already registered events
class AlreadyRegisteredException implements Exception {
  final String message;
  AlreadyRegisteredException(this.message);
  
  @override
  String toString() => message;
}
