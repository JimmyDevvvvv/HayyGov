import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdFeedScreen extends StatelessWidget {
  const AdFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final approvedAdsRef = FirebaseFirestore.instance
        .collection('ads')
        .where('approved', isEqualTo: true)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Neighborhood Ads"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: approvedAdsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No approved ads yet."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final title = data['title'] ?? '';
              final desc = data['description'] ?? '';
              final imageUrl = data['imageUrl'];
              final advertiserId = data['advertiserId'];

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(advertiserId).get(),
                builder: (context, userSnapshot) {
                  String displayName = advertiserId;
                  if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                    if (userData != null && userData.containsKey('email')) {
                      displayName = userData['email'];
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(desc),
                          trailing: Text(displayName, style: const TextStyle(fontSize: 11)),
                        ),
                        if (imageUrl != null && imageUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                          ),
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
