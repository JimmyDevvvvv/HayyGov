// services/local_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/emergency_contact.dart';

class LocalStorageService {
  static const _key = 'emergency_contacts';

  Future<void> saveContacts(List<EmergencyContact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final data = contacts.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_key, data);
  }

  Future<List<EmergencyContact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(_key);
    if (data == null) return [];
    return data.map((json) {
      final map = jsonDecode(json);
      return EmergencyContact.fromJson(map);
    }).toList();
  }
}
