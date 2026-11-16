import 'package:hive_flutter/hive_flutter.dart';

import '../models/money_entry.dart';

/// Save and loads transactions on the phone
class MoneyService {
  static const String _boxName = 'money_entries';
  static late Box _box;

  /// Call once when the app starts
  static Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// All transactions, newest first.
  static List<MoneyEntry> getAll() {
    final list = _box.values
        .map((item) => MoneyEntry.fromMap(item as Map))
        .toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  /// Only yhe transaction of one day
  static List<MoneyEntry> getForDay(DateTime day) {
    return getAll().where((e) => _isSameDay(e.date, day)).toList();
  }

  static Future<void> add(MoneyEntry entry) =>
      _box.put(entry.id, entry.toMap());
  static Future<void> delete(String id) => _box.delete(id);
  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
