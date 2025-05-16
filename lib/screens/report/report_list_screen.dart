import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ReportListScreen extends StatelessWidget {
  const ReportListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reportsRef = FirebaseFirestore.instance
        .collection('reports')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Submitted Reports"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: reportsRef.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No reports submitted yet."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final userId = data['userId'];
              final content = data['content'];
              final timestamp = (data['timestamp'] as Timestamp).toDate();
              final imageUrl = data['imageUrl'] ?? '';
              final location = data['location'] ?? '';

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(userId).get(),
                builder: (context, userSnapshot) {
                  String displayName = userId;
                  if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                    final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                    if (userData != null && userData.containsKey('email')) {
                      displayName = userData['email'];
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text("From: $displayName"),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(content),
                          if (imageUrl.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Image.network(imageUrl, height: 150, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Text('Could not load image')), 
                          ],
                          if (location.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text("📍 Location: $location", style: const TextStyle(fontSize: 13)),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            "Submitted at: ${timestamp.toLocal()}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
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
