import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../models/event.dart';

class EventProvider extends ChangeNotifier {
  List<Event> _events = [];
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedMonth = DateTime.now();
  Database? _db;

  List<Event> get events => _events;
  DateTime get selectedDate => _selectedDate;
  DateTime get focusedMonth => _focusedMonth;

  List<Event> get eventsForSelectedDate {
    return _events.where((e) =>
      e.date.year == _selectedDate.year &&
      e.date.month == _selectedDate.month &&
      e.date.day == _selectedDate.day
    ).toList()..sort((a, b) {
      if (a.isAllDay && !b.isAllDay) return -1;
      if (!a.isAllDay && b.isAllDay) return 1;
      final aMin = a.startTime != null ? a.startTime!.hour * 60 + a.startTime!.minute : 0;
      final bMin = b.startTime != null ? b.startTime!.hour * 60 + b.startTime!.minute : 0;
      return aMin.compareTo(bMin);
    });
  }

  List<Event> getEventsForDate(DateTime date) {
    return _events.where((e) =>
      e.date.year == date.year && e.date.month == date.month && e.date.day == date.day
    ).toList();
  }

  int getEventCountForDate(DateTime date) => getEventsForDate(date).length;

  void selectDate(DateTime date) { _selectedDate = date; notifyListeners(); }
  void setFocusedMonth(DateTime month) {
    _focusedMonth = DateTime(month.year, month.month, 1);
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _db = await _initDB();
    final maps = await _db!.query('events', orderBy: 'date ASC');
    _events = maps.map((m) => Event.fromMap(m)).toList();
    notifyListeners();
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      p.join(dbPath, 'schedule.db'),
      version: 1,
      onCreate: (db, v) => db.execute('''
        CREATE TABLE events(
          id TEXT PRIMARY KEY,
          title TEXT NOT NULL,
          description TEXT,
          date TEXT NOT NULL,
          startHour INTEGER,
          startMinute INTEGER,
          endHour INTEGER,
          endMinute INTEGER,
          colorIndex INTEGER DEFAULT 0,
          isAllDay INTEGER DEFAULT 0
        )
      '''),
    );
  }

  Future<void> addEvent(Event event) async {
    await _db!.insert('events', event.toMap());
    _events.add(event);
    notifyListeners();
  }

  Future<void> updateEvent(Event event) async {
    await _db!.update('events', event.toMap(), where: 'id = ?', whereArgs: [event.id]);
    final idx = _events.indexWhere((e) => e.id == event.id);
    if (idx >= 0) _events[idx] = event;
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    await _db!.delete('events', where: 'id = ?', whereArgs: [id]);
    _events.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}
