import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyAdsScreen extends StatelessWidget {
  const MyAdsScreen({super.key});

  Future<void> _deleteAd(BuildContext context, String adId) async {
    try {
      await FirebaseFirestore.instance.collection('ads').doc(adId).delete();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ad deleted successfully")));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete: $e")));
    }
  }

  void _editAd(BuildContext context, String adId, Map<String, dynamic> currentData) {
    final titleController = TextEditingController(text: currentData['title']);
    final descController = TextEditingController(text: currentData['description']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Edit Advertisement"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Title")),
            const SizedBox(height: 8),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "Description")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('ads').doc(adId).update({
                  'title': titleController.text.trim(),
                  'description': descController.text.trim(),
                  'approved': false, // Needs re-approval
                  'disapproved': false, // Reset disapproval if any
                  'timestamp': Timestamp.now(),
                });
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ad updated. Awaiting re-approval.")));
              } catch (e) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Update failed: $e")));
              }
            },
            child: const Text("Save"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Center(child: Text("❌ Not logged in."));
    }

    final adQuery = FirebaseFirestore.instance
        .collection('ads')
        .where('advertiserId', isEqualTo: uid)
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("My Ads")),
      body: StreamBuilder<QuerySnapshot>(
        stream: adQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("🔥 Error: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("📭 You haven't posted any ads yet."));

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final ad = doc.data() as Map<String, dynamic>;
              final title = ad['title'] ?? '';
              final description = ad['description'] ?? '';
              final imageUrl = ad['imageUrl'];
              final approved = ad['approved'] ?? false;
              final disapproved = ad['disapproved'] ?? false;

              String status = approved
                  ? "✅ Approved"
                  : disapproved
                      ? "❌ Disapproved"
                      : "⏳ Awaiting approval";

              Color statusColor = approved
                  ? Colors.green
                  : disapproved
                      ? Colors.red
                      : Colors.orange;

              return Card(
                margin: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(title),
                      subtitle: Text(description),
                      trailing: Text(status, style: TextStyle(color: statusColor)),
                    ),
                    if (imageUrl != null && imageUrl.isNotEmpty)
                      Image.network(imageUrl, height: 200, fit: BoxFit.cover),
                    OverflowBar(
                      children: [
                        TextButton.icon(
                          onPressed: () => _editAd(context, doc.id, ad),
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                        ),
                        TextButton.icon(
                          onPressed: () => _deleteAd(context, doc.id),
                          icon: const Icon(Icons.delete, color: Colors.red),
                          label: const Text("Delete"),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
