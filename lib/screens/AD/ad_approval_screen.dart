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
              final location = data['location'] ?? '';
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
                    margin: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(title ?? ''),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(desc ?? ''),
                              if (location.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(location, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              Text('Advertiser: $advertiserEmail', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Image.network(imageUrl, height: 200, fit: BoxFit.cover),
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
