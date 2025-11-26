import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final eventsServiceProvider = Provider((ref) => EventsService());

final userEventsProvider = StreamProvider<List<CalendarEvent>>((ref) {
  final service = ref.watch(eventsServiceProvider);
  return service.getEvents();
});

class EventsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Etkinlikleri stream olarak dinle
  Stream<List<CalendarEvent>> getEvents() {
    if (_userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('events')
        .orderBy('date', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CalendarEvent(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          time: data['time'] ?? '',
          color: data['color'] ?? 0xFF1173d4,
          reminderEnabled: data['reminderEnabled'] ?? false,
        );
      }).toList();
    });
  }

  // Belirli bir tarihteki etkinlikleri getir
  Stream<List<CalendarEvent>> getEventsByDate(DateTime date) {
    if (_userId == null) return Stream.value([]);

    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection('users')
        .doc(_userId)
        .collection('events')
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .orderBy('date')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CalendarEvent(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          time: data['time'] ?? '',
          color: data['color'] ?? 0xFF1173d4,
          reminderEnabled: data['reminderEnabled'] ?? false,
        );
      }).toList();
    });
  }

  // Yeni etkinlik ekle
  Future<void> addEvent({
    required String title,
    required String description,
    required DateTime date,
    required String time,
    int color = 0xFF1173d4,
    bool reminderEnabled = false,
  }) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('events')
        .add({
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'time': time,
      'color': color,
      'reminderEnabled': reminderEnabled,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Etkinliği güncelle
  Future<void> updateEvent({
    required String eventId,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    int? color,
    bool? reminderEnabled,
  }) async {
    if (_userId == null) return;

    final Map<String, dynamic> updates = {};
    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (date != null) updates['date'] = Timestamp.fromDate(date);
    if (time != null) updates['time'] = time;
    if (color != null) updates['color'] = color;
    if (reminderEnabled != null) updates['reminderEnabled'] = reminderEnabled;

    if (updates.isEmpty) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('events')
        .doc(eventId)
        .update(updates);
  }

  // Etkinliği sil
  Future<void> deleteEvent(String eventId) async {
    if (_userId == null) return;

    await _firestore
        .collection('users')
        .doc(_userId)
        .collection('events')
        .doc(eventId)
        .delete();
  }
}

class CalendarEvent {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final int color;
  final bool reminderEnabled;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.color,
    required this.reminderEnabled,
  });
}
