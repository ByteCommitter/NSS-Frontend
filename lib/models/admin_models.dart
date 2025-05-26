
// Event class definition
class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String fromTime;
  final String toTime;
  final String location;
  final String? imageUrl;

  Event({
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

// Basic models for admin functionality

// Define AdminEventModel to avoid conflicts with other Event classes
class AdminEvent {
  final String id;
  final String title;
  final String description;
  final String date;
  final String fromTime;
  final String toTime;
  final String location;
  final String? imageUrl;

  AdminEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.location,
    this.imageUrl,
  });
  
  // Factory to create from ApiEvent
  factory AdminEvent.fromEvent(dynamic event) {
    return AdminEvent(
      id: event.id,
      title: event.title,
      description: event.description ?? '',
      date: event.date,
      fromTime: event.fromTime,
      toTime: event.toTime,
      location: event.location,
      imageUrl: event.imageUrl,
    );
  }
}

class AdminUpdate {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  AdminUpdate({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });
}

class AdminUser {
  final String id;
  final String name;
  final int points;
  final String? imageUrl;
  final int rank;

  AdminUser({
    required this.id,
    required this.name,
    required this.points,
    this.imageUrl,
    required this.rank,
  });
}
