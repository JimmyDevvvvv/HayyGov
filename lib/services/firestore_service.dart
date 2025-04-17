import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/emergency_contact.dart';
import 'local_storage_service.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  final _localStorage = LocalStorageService();

  Future<bool> _isOnline() async {
    final result = await Connectivity().checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<List<EmergencyContact>> getContacts() async {
    final online = await _isOnline();

    if (online) {
      try {
        final snapshot = await _db.collection('emergency_numbers').get();
        final contacts = snapshot.docs
            .map((doc) => EmergencyContact.fromFirestore(doc.data()))
            .toList();

        await _localStorage.saveContacts(contacts); // cache data
        return contacts;
      } catch (e) {
        return await _localStorage.loadContacts(); // fallback on error
      }
    } else {
      return await _localStorage.loadContacts(); // offline fallback
    }
  }
}
