import 'dart:convert';
import 'dart:async'; // Added missing import for TimeoutException
// lowercase math to follow convention
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:mentalsustainability/pages/Home/home_page.dart' hide Event; // Hide Event from home_page
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/models/admin_models.dart'; // Keep this import for Event

// Update the ApiEvent class to include points
class ApiEvent {
  final String id;
  final String title;
  final String description;
  final String date;
  final String fromTime;
  final String toTime;
  final String location;
  final String? imageUrl;
  final int? points; // Make sure points is included in the model

  ApiEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.location,
    this.imageUrl,
    this.points = 50, // Default to 50 points
  });

  // ...existing code for fromJson if any...
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date,
      'fromTime': fromTime,
      'toTime': toTime,
      'location': location,
      if (imageUrl != null) 'imageUrl': imageUrl,
      'points': points ?? 0, // Include points in JSON with default
    };
  }
}



class ApiService extends GetxService {
  String get baseUrl {
    return ApiConfig.apiBase; // This points to your HTTP AWS backend
  }
  
  
  
  final AuthService _authService = Get.find<AuthService>();
  
  // Add the missing getToken method
  Future<String?> getToken() async {
    return await _authService.getToken();
  }
  
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
      // NEW: Add timeout to prevent hanging
      final response = await http.post(
        Uri.parse('${baseUrl}auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': id,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15)); // Add 15 second timeout
      
      print('Login response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Debug: Print the full response to see what we're getting
        print('Full login response data: $responseData');
        
        // The backend now sends a complete response with all user info
        // Just return it directly without needing to create a new structure
        return responseData;
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
      
      // NEW: Add timeout to prevent hanging
      final response = await http.get(
        Uri.parse('${baseUrl}events/'),
        headers: {
          'Authorization': token, // Sending token as-is as per API requirements
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15)); // Add 15 second timeout
      
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
            
            // Debug: Print the banner_image field
            print('Raw banner_image from API: ${eventJson['banner_image']}');
            
            return ApiEvent(
              id: eventJson['id'].toString(),
              title: eventJson['title'] ?? 'Untitled Event',
              description: eventJson['description'] ?? 'No description available',
              date: eventJson['date'] ?? 'TBD',
              fromTime: eventJson['fromTime'] ?? '00:00:00',
              toTime: eventJson['ToTime'] ?? '00:00:00', // Note: API uses 'ToTime' with capital T
              location: eventJson['eventVenue'] ?? 'TBD',
              imageUrl: eventJson['banner_image'], // Map banner_image to imageUrl
              points: eventJson['points'] != null ? int.tryParse(eventJson['points'].toString()) : 50, // Add points mapping
            );
          }).toList();
          
          // Debug: Print the final events with their imageUrls
          for (var event in events) {
            print('Event "${event.title}" has imageUrl: "${event.imageUrl}"');
          }
          
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
  Future<ApiEvent?> getEventById(String eventId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return null;
      }
      
      final response = await http.post(
        Uri.parse('${baseUrl}events/eventById'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': eventId,
        }),
      );
      
      print('Get event by ID response: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        // Handle the actual API response format with result array
        dynamic eventData;
        if (responseData is Map && responseData.containsKey('result')) {
          final resultArray = responseData['result'] as List<dynamic>;
          if (resultArray.isNotEmpty) {
            eventData = resultArray[0]; // Get the first (and likely only) event
          } else {
            print('No event found in result array');
            return null;
          }
        } else {
          // Fallback for direct event data format
          eventData = responseData;
        }
        
        return ApiEvent(
          id: eventData['id'].toString(),
          title: eventData['title'] ?? 'Unknown Event',
          description: eventData['description'] ?? 'No description available',
          date: eventData['date'] ?? 'TBD',
          fromTime: eventData['fromTime'] ?? '00:00:00',
          toTime: eventData['ToTime'] ?? '00:00:00',
          location: eventData['eventVenue'] ?? 'TBD',
          imageUrl: eventData['banner_image'], // Map banner_image to imageUrl
          points: eventData['points'] != null ? int.tryParse(eventData['points'].toString()) : 50, // Add points mapping
        );
      } else {
        print('Failed to fetch event $eventId: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error fetching event $eventId: $e');
      return null;
    }
  }
  Future<bool> createEvent(ApiEvent event) async {
    try {
      final token = await _authService.getToken();
      
      // FIXED: Parse the date and combine it with times to create full DateTime objects
      DateTime eventDate;
      try {
        eventDate = DateTime.parse(event.date);
      } catch (e) {
        print('Error parsing date: ${event.date} - $e');
        return false;
      }
      
      // FIXED: Create proper DateTime objects by combining date with times
      DateTime fromDateTime;
      DateTime toDateTime;
      
      try {
        final fromTimeParts = event.fromTime.split(':');
        final toTimeParts = event.toTime.split(':');
        
        fromDateTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          int.parse(fromTimeParts[0]),
          int.parse(fromTimeParts[1]),
          fromTimeParts.length > 2 ? int.parse(fromTimeParts[2]) : 0,
        );
        
        toDateTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          int.parse(toTimeParts[0]),
          int.parse(toTimeParts[1]),
          toTimeParts.length > 2 ? int.parse(toTimeParts[2]) : 0,
        );
      } catch (e) {
        print('Error parsing times in createEvent - fromTime: ${event.fromTime}, toTime: ${event.toTime} - $e');
        return false;
      }

      final response = await http.post(
        Uri.parse('${baseUrl}events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token ?? '',
        },
        body: json.encode({
          'title': event.title,
          'description': event.description,
          'date': eventDate.toIso8601String(),
          'fromTime': fromDateTime.toIso8601String(),
          'toTime': toDateTime.toIso8601String(), // Note: lowercase 't' for create
          'eventVenue': event.location,
          'banner_image': event.imageUrl,
          'points': event.points ?? 50,
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
    
    print('Fetching registered events for user ID: $userId');
    print('Using token: ${token.substring(0, 20)}...');
    
    // Use the exact endpoint format you provided
    final response = await http.get(
      Uri.parse('${baseUrl}events/user-event?query=eventsForUser&user_id=$userId'),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json',
      },
    );
    
    print('Get user registered events response: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      try {
        final responseData = json.decode(response.body);
        print('Parsed response data: $responseData');
        
        List<dynamic> eventIds = [];
        
        // Handle the response format from your server
        if (responseData is Map && responseData.containsKey('result')) {
          eventIds = responseData['result'] as List<dynamic>;
          print('Found result array with ${eventIds.length} event registrations');
        } else {
          print('Unexpected response format: $responseData');
          return [];
        }
        
        // Check if the result array is empty
        if (eventIds.isEmpty) {
          print('No registered events found for user $userId');
          return [];
        }
        
        // Since your server returns event_ids, we need to fetch full event details
        List<ApiEvent> registeredEvents = [];
        
        for (var eventData in eventIds) {
          String eventId;
          if (eventData is Map && eventData.containsKey('event_id')) {
            eventId = eventData['event_id'].toString();
          } else {
            eventId = eventData.toString();
          }
          
          print('Fetching details for event ID: $eventId');
          
          // Fetch full event details for each registered event
          try {
            final eventDetails = await getEventById(eventId);
            if (eventDetails != null) {
              registeredEvents.add(eventDetails);
              print('Successfully fetched details for event $eventId: ${eventDetails.title}');
            } else {
              print('Could not fetch details for event $eventId, creating placeholder');
              // Create a placeholder event with minimal info
              registeredEvents.add(ApiEvent(
                id: eventId,
                title: 'Event #$eventId (Details Unavailable)',
                description: 'Event details could not be loaded from server',
                date: 'TBD',
                fromTime: '00:00:00',
                toTime: '00:00:00',
                location: 'TBD',
                imageUrl: null,
              ));
            }
          } catch (e) {
            print('Error fetching details for event $eventId: $e');
            // Still add a placeholder so user knows they're registered
            registeredEvents.add(ApiEvent(
              id: eventId,
              title: 'Registered Event #$eventId',
              description: 'Unable to load event details at this time',
              date: 'TBD',
              fromTime: '00:00:00',
              toTime: '00:00:00',
              location: 'Check with organizers',
              imageUrl: null,
            ));
          }
        }
        
        print('Successfully processed ${registeredEvents.length} registered events');
        return registeredEvents;
        
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

// Add a debug method to check what user ID is being used
Future<void> debugUserInfo() async {
  final token = await _authService.getToken();
  final userId = await _authService.getUserId();
  
  print('=== DEBUG USER INFO ===');
  print('Token available: ${token != null}');
  if (token != null) {
    print('Token preview: ${token.substring(0, 20)}...');
  }
  print('User ID: $userId');
  print('User ID type: ${userId.runtimeType}');
  print('========================');
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
    // Implement the postNotification method that we already defined
    await postNotification(title, message);
  }

  // Updated updateEvent method to fix datetime formatting
  Future<bool> updateEvent(
    String eventId,
    String title,
    String description,
    String date,
    String fromTime,
    String toTime,
    String location,
    String? bannerImage,
    int points,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        print('No token available for updating event');
        return false;
      }

      print('Updating event with ID: $eventId');
      
      // FIXED: Parse the date and combine it with the time to create full DateTime objects
      DateTime eventDate;
      try {
        eventDate = DateTime.parse(date);
      } catch (e) {
        print('Error parsing date: $date - $e');
        return false;
      }
      
      // FIXED: Create proper DateTime objects by combining date with times
      DateTime fromDateTime;
      DateTime toDateTime;
      
      try {
        // Parse time strings (format: "HH:mm:ss" or "HH:mm")
        final fromTimeParts = fromTime.split(':');
        final toTimeParts = toTime.split(':');
        
        fromDateTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          int.parse(fromTimeParts[0]), // hours
          int.parse(fromTimeParts[1]), // minutes
          fromTimeParts.length > 2 ? int.parse(fromTimeParts[2]) : 0, // seconds
        );
        
        toDateTime = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
          int.parse(toTimeParts[0]), // hours
          int.parse(toTimeParts[1]), // minutes
          toTimeParts.length > 2 ? int.parse(toTimeParts[2]) : 0, // seconds
        );
      } catch (e) {
        print('Error parsing times - fromTime: $fromTime, toTime: $toTime - $e');
        return false;
      }

      // Convert to ISO strings for the API
      final requestBody = {
        'id': int.tryParse(eventId) ?? eventId,
        'title': title,
        'description': description,
        'date': eventDate.toIso8601String(),
        'fromTime': fromDateTime.toIso8601String(), // Full datetime
        'ToTime': toDateTime.toIso8601String(), // Full datetime with capital T as expected by API
        'eventVenue': location,
        'banner_image': bannerImage,
        'points': points,
      };

      print('Request data: ${jsonEncode(requestBody)}');

      final response = await http.put(
        Uri.parse('${baseUrl}events'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': token,
        },
        body: jsonEncode(requestBody),
      );

      print('Update event response status: ${response.statusCode}');
      print('Update event response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['message'] == 'Event Updated') {
          print('Event updated successfully');
          return true;
        }
      }

      print('Failed to update event: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      print('Error updating event: $e');
      return false;
    }
  }

  // Updated method to get registered users for an event with the correct endpoint
  Future<List<Map<String, dynamic>>> getEventRegisteredUsers(String eventId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return [];
      }
      
      // Updated to use the correct query parameter: usersForEvents (with 's')
      final response = await http.get(
        Uri.parse('${baseUrl}events/user-event?query=usersForEvents&event_id=$eventId'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );
      
      print('Get registered users response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData.containsKey('result') && responseData['result'] is List) {
          return List<Map<String, dynamic>>.from(responseData['result']);
        }
        return [];
      } else {
        print('Failed to fetch registered users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching registered users: $e');
      return [];
    }
  }
  
  // Method to verify a user's attendance at an event
  Future<bool> verifyUserAttendance(String eventId, String userId, bool verified) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      // Request body based on the provided API format
      final requestBody = {
        'user_id': userId,
        'event_id': eventId,
        'isParticipated': verified ? 1 : 0, // 1 for verified, 0 for unverified
      };
      
      print('Verifying user attendance: $requestBody');
      
      final response = await http.put(
        Uri.parse('${baseUrl}events/user-event/'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json'
        },
        body: json.encode(requestBody),
      );
      
      print('Verify attendance response: ${response.statusCode} - ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error verifying attendance: $e');
      return false;
    }
  }

  // Fetch all notifications
  Future<List<Map<String, dynamic>>> getNotifications() async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('${baseUrl}notifications'),
        headers: {
          'Authorization': token,
        },
      );
      
      print('Get notifications response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData.containsKey('result') && responseData['result'] is List) {
          return List<Map<String, dynamic>>.from(responseData['result']);
        }
        return [];
      } else {
        print('Failed to fetch notifications: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }
  
  // Post a new notification
  Future<bool> postNotification(String title, String message) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      // Create notification payload
      final notification = {
        'title': title,
        'message': message,
        'time': DateTime.now().toUtc().toIso8601String(),
        'isRead': false
      };
      
      final response = await http.post(
        Uri.parse('${baseUrl}notifications'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode(notification),
      );
      
      print('Post notification response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData['success'] == true;
      } else {
        print('Failed to post notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error posting notification: $e');
      return false;
    }
  }

  // Delete a notification - FIXED: Handle string IDs properly
  Future<bool> deleteNotification(dynamic notificationId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      // Convert string ID to int if necessary
      int id;
      if (notificationId is String) {
        id = int.tryParse(notificationId) ?? 0;
        if (id == 0) {
          print('Invalid notification ID: $notificationId');
          return false;
        }
      } else if (notificationId is int) {
        id = notificationId;
      } else {
        print('Invalid notification ID type: ${notificationId.runtimeType}');
        return false;
      }
      
      print('Deleting notification with ID: $id (converted from $notificationId)');
      
      final response = await http.delete(
        Uri.parse('${baseUrl}notifications'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'id': id
        }),
      );
      
      print('Delete notification response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['isSuccess'] == true;
      } else {
        print('Failed to delete notification: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  // Soft delete event method (just marks as deleted in the database)
  Future<bool> softDeleteEvent(String id) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      final response = await http.put(
        Uri.parse('${baseUrl}events/softDelete'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'id': id,
        }),
      );
      
      print('Soft delete event response: ${response.statusCode} - ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error soft deleting event: $e');
      return false;
    }
  }
  
  // Hard delete event method (completely removes from database)
  Future<bool> hardDeleteEvent(String id) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      final response = await http.delete(
        Uri.parse('${baseUrl}events/hardDelete'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json'
        },
        body: json.encode({
          'id': id,
        }),
      );
      
      print('Hard delete event response: ${response.statusCode} - ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error hard deleting event: $e');
      return false;
    }
  }

  // Get all users for admin dashboard
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('${baseUrl}maintenance/users'),
        headers: {
          'Authorization': token,
        },
      );
      
      print('Get all users response: ${response.statusCode}');
      print('Raw response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData.containsKey('result') && responseData['result'] is List) {
          final usersList = List<Map<String, dynamic>>.from(responseData['result']);
          
          // Debug: Print basic user data structure
          if (usersList.isNotEmpty) {
            print('Sample user data structure: ${usersList[0].keys.toList()}');
            print('isVolunteer: ${usersList[0]['isVolunteer']} (type: ${usersList[0]['isVolunteer'].runtimeType})');
            print('isWishVolunteer: ${usersList[0]['isWishVolunteer']} (type: ${usersList[0]['isWishVolunteer'].runtimeType})');
          }
          
          return usersList;
        }
        return [];
      } else {
        print('Failed to fetch users: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
  
  // Get volunteers (users with isVolunteer = 1)
  Future<List<Map<String, dynamic>>> getVolunteers() async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return [];
      }
      
      final response = await http.get(
        Uri.parse('${baseUrl}maintenance/volunteers'),
        headers: {
          'Authorization': token,
        },
      );
      
      print('Get volunteers response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData.containsKey('result') && responseData['result'] is List) {
          return List<Map<String, dynamic>>.from(responseData['result']);
        }
        return [];
      } else {
        print('Failed to fetch volunteers: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching volunteers: $e');
      return [];
    }
  }
  
  // Delete a user (admin only)
  Future<bool> deleteUser(String universityId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      final response = await http.delete(
        Uri.parse('${baseUrl}maintenance/users'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'university_id': universityId
        }),
      );
      
      print('Delete user response: ${response.statusCode} - ${response.body}');
      
      return response.statusCode == 200;
    } catch (e) {
      print('Error deleting user: $e');
      return false;
    }
  }
  
  // Request to become a volunteer (user action)
  Future<Map<String, dynamic>> wishToBeVolunteer(String universityId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return {'success': false, 'message': 'Authentication required'};
      }
      
      final response = await http.put(
        Uri.parse('${baseUrl}maintenance/wishVolunteer'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'university_id': universityId
        }),
      );
      
      print('Wish to be volunteer response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': responseData['isSuccess'] == true,
          'message': responseData['Message'] ?? 'Registered to be a volunteer'
        };
      } else if (response.statusCode == 501) {
        return {'success': false, 'message': 'Unable to register as volunteer'};
      }
      return {'success': false, 'message': 'An unexpected error occurred'};
    } catch (e) {
      print('Error requesting volunteer status: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
  
  // Make a user a volunteer (admin action)
  Future<bool> makeVolunteer(String universityId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      final response = await http.put(
        Uri.parse('${baseUrl}maintenance/makeVolunteer'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'university_id': universityId
        }),
      );
      
      print('Make volunteer response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('Error making user a volunteer: $e');
      return false;
    }
  }
  
  // Remove volunteer status (admin action)
  Future<bool> removeVolunteer(String universityId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      print('Removing volunteer status for: $universityId'); // Debug log
      
      final response = await http.put(
        Uri.parse('${baseUrl}maintenance/removeVolunteer'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'university_id': universityId
        }),
      );
      
      print('Remove volunteer response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('Error removing volunteer status: $e');
      return false;
    }
  }
  
  // Reject volunteer request (admin action)
  Future<bool> rejectVolunteerRequest(String universityId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return false;
      }
      
      final response = await http.put(
        Uri.parse('${baseUrl}maintenance/rejectVolunteer'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'university_id': universityId
        }),
      );
      
      print('Reject volunteer request response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['isSuccess'] == true;
      }
      return false;
    } catch (e) {
      print('Error rejecting volunteer request: $e');
      return false;
    }
  }

  // Get total points for a user
Future<int> getUserTotalPoints(String userId) async {
  try {
    final token = await _authService.getToken();
    
    if (token == null) {
      print('No auth token available');
      return 0;
    }
    
    final response = await http.get(
      Uri.parse('${baseUrl}dashboard/pointsScored?user_id=$userId'),
      headers: {
        'Authorization': token,
      },
    );
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['points'] ?? 0;
    } else {
      print('Failed to fetch user points: ${response.statusCode}');
      return 0;
    }
  } catch (e) {
    print('Error fetching user points: $e');
    return 0;
  }
}

// Get top volunteers
Future<List<Map<String, dynamic>>> getTopVolunteers() async {
  try {
    final token = await _authService.getToken();
    
    if (token == null) {
      print('No auth token available');
      return [];
    }
    
    final response = await http.get(
      Uri.parse('${baseUrl}dashboard/topVolunteers/'),
      headers: {
        'Authorization': token,
      },
    );
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData.containsKey('topVolunteers') && responseData['topVolunteers'] is List) {
        return List<Map<String, dynamic>>.from(responseData['topVolunteers']);
      }
      return [];
    } else {
      print('Failed to fetch top volunteers: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching top volunteers: $e');
    return [];
  }
}

// Get recent participations for a user
Future<List<Map<String, dynamic>>> getRecentParticipations(String userId) async {
  try {
    final token = await _authService.getToken();
    
    if (token == null) {
      print('No auth token available');
      return [];
    }
    
    final response = await http.get(
      Uri.parse('${baseUrl}dashboard/recentParticipations?user_id=$userId'),
      headers: {
        'Authorization': token,
      },
    );
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData.containsKey('Participations') && responseData['Participations'] is List) {
        return List<Map<String, dynamic>>.from(responseData['Participations']);
      }
      return [];
    } else {
      print('Failed to fetch recent participations: ${response.statusCode}');
      return [];
    }
  } catch (e) {
    print('Error fetching recent participations: $e');
    return [];
  }
}
  
  // Get current user info - use this instead of login for refreshing status
  Future<Map<String, dynamic>?> getUserInfo(String userId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return null;
      }
      
      // Use the maintenance/user endpoint to get user info
      final response = await http.get(
        Uri.parse('${baseUrl}maintenance/user?university_id=$userId'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );
      
      print('Get user info response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['user'];
      }
      
      return null;
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }

  // Get volunteer status from the new endpoint - FIX URL PATH
  Future<Map<String, dynamic>> getVolunteerStatus(String universityId) async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return {'verificationStatus': -1}; // Default to normal user
      }
      
      // Fix: Added the "dashboard/" prefix to the URL path
      final response = await http.get(
        Uri.parse('${baseUrl}maintenance/volunteerStatus?id=$universityId'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      );
      
      print('Get volunteer status response: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        // Default to normal user on error
        return {'verificationStatus': -1};
      }
    } catch (e) {
      print('Error getting volunteer status: $e');
      return {'verificationStatus': -1}; // Default to normal user
    }
  }

  // Add method to get past events (notifications/eventUpdates) with Redis cache handling
  Future<List<Map<String, dynamic>>> getPastEvents() async {
    try {
      final token = await _authService.getToken();
      
      if (token == null) {
        print('No auth token available');
        return [];
      }
      
      print('Fetching event updates from: ${baseUrl}notifications');
      
      final response = await http.get(
        Uri.parse('${baseUrl}notifications'),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('Event updates request timed out');
          throw TimeoutException('Request timed out', const Duration(seconds: 10));
        },
      );
      
      print('Get event updates response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);
          List<dynamic> eventsData;
          
          // Handle Redis cache inconsistency
          if (responseData is List) {
            // Direct array from Redis cache
            eventsData = responseData;
            print('Got cached event updates (direct array): ${eventsData.length} items');
          } else if (responseData is Map && responseData.containsKey('result')) {
            // Wrapped format when not cached
            eventsData = responseData['result'] as List<dynamic>;
            print('Got fresh event updates (wrapped): ${eventsData.length} items');
          } else {
            print('Unexpected response format: $responseData');
            return [];
          }
          
          // Convert notification format to expected format
          return eventsData.map((item) => {
            'id': item['id']?.toString() ?? '',
            'title': item['title'] ?? 'Untitled Notification',
            'message': item['message'] ?? 'No message',
            'time': item['time'] ?? item['createdAt'] ?? DateTime.now().toIso8601String(),
            'isRead': item['isRead'] ?? false,
          }).toList().cast<Map<String, dynamic>>();
          
        } catch (parseError) {
          print('Error parsing event updates: $parseError');
          print('Raw response: ${response.body}');
          return [];
        }
      } else {
        print('Failed to load event updates: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception fetching event updates: $e');
      return [];
    }
  }
}

// Custom exception for already registered events
class AlreadyRegisteredException implements Exception {
  final String message;
  AlreadyRegisteredException(this.message);
  
  @override
  String toString() => message;
}
