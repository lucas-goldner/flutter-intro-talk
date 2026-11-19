import 'package:flutter/foundation.dart';

/// Model — an immutable meetup event.
@immutable
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.venue,
    this.isFavorite = false,
  });

  factory Event.fromJson(Map<String, Object?> json) => switch (json) {
    {
      'id': final String id,
      'title': final String title,
      'starts_at': final String startsAt,
      'venue': final String venue,
    } =>
      Event(
        id: id,
        title: title,
        startsAt: DateTime.parse(startsAt),
        venue: venue,
        isFavorite: json['is_favorite'] == true,
      ),
    _ => throw FormatException('Invalid event: $json'),
  };

  final String id;
  final String title;
  final DateTime startsAt;
  final String venue;
  final bool isFavorite;

  Event copyWith({bool? isFavorite}) => Event(
    id: id,
    title: title,
    startsAt: startsAt,
    venue: venue,
    isFavorite: isFavorite ?? this.isFavorite,
  );
}
