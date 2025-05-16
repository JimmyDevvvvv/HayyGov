import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdApprovalScreen extends StatelessWidget {
  const AdApprovalScreen({super.key});

  Future<void> _approveAd(String adId) async {
    await FirebaseFirestore.instance.collection('ads').doc(adId).update({
      'approved': true,
    });
  }

  Future<void> _deleteAd(String adId) async {
    await FirebaseFirestore.instance.collection('ads').doc(adId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final unapprovedAdsRef = FirebaseFirestore.instance
        .collection('ads')
        .where('approved', isEqualTo: false)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve Advertisements"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: unapprovedAdsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No ads awaiting approval."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final adId = docs[index].id;
              final title = data['title'];
              final desc = data['description'];
              final imageUrl = data['imageUrl'];
              final advertiserId = data['advertiserId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(advertiserId).get(),
                builder: (context, userSnapshot) {
                  String advertiserEmail = advertiserId;
                  if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                    if (userData != null && userData.containsKey('email')) {
                      advertiserEmail = userData['email'];
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(title),
                          subtitle: Text(desc),
                          trailing: Text("From: $advertiserEmail", style: const TextStyle(fontSize: 12)),
                        ),
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                          ),
                        OverflowBar(
                          alignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _approveAd(adId),
                              icon: const Icon(Icons.check),
                              label: const Text("Approve"),
                            ),
                            OutlinedButton.icon(
                              onPressed: () => _deleteAd(adId),
                              icon: const Icon(Icons.delete),
                              label: const Text("Delete"),
                              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
