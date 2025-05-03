import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/poll.dart';
import '../device_id.dart'; // ✅ now correct based on your current setup


class PollService {
  final _db = FirebaseFirestore.instance;

  Stream<List<Poll>> getPolls() {
    return _db.collection('Polls').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Poll.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  Future<void> vote(String pollId, String choice) async {
    final userId = await DeviceId.getId(); // 👈 Use device ID instead of Firebase Auth

    final docRef = _db.collection('Polls').doc(pollId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? {};

      List<dynamic> voters = data['Voters'] ?? [];

      if (voters.contains(userId)) {
        throw Exception("You’ve already voted!");
      }

      final updatedFields = {
        'Voters': FieldValue.arrayUnion([userId]),
        if (choice == 'yes') 'Yes': (data['Yes'] ?? 0) + 1,
        if (choice == 'no') 'No': (data['No'] ?? 0) + 1,
      };

      transaction.update(docRef, updatedFields);
    });
  }
}
