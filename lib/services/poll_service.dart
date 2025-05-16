import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/poll.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final userId = user.uid;

    final docRef = _db.collection('Polls').doc(pollId);

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      final data = snapshot.data() ?? {};

      List<dynamic> voters = data['Voters'] ?? [];

      if (voters.contains(userId)) {
        throw Exception("You've already voted!");
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
