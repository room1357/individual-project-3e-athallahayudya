import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

class SharedPrefsStorage {
  static const _key = 'expenses';

  static Future<List<Expense>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString(_key);
    if (s == null) return [];
    final List<dynamic> decoded = jsonDecode(s);
    return decoded.map((e) => Expense.fromJson(e as Map<String, dynamic>)).toList();
  }

  static Future<void> saveAll(List<Expense> list) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<void> addExpense(Expense e) async {
    final list = await loadAll();
    list.insert(0, e);
    await saveAll(list);
  }

  static Future<void> deleteById(String id) async {
    final list = await loadAll();
    list.removeWhere((x) => x.id == id);
    await saveAll(list);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}