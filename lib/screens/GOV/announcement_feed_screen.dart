import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'create_announcement_screen.dart';

class AnnouncementFeedScreen extends StatelessWidget {
  const AnnouncementFeedScreen({super.key});

  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat('yyyy/MM/dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Announcements')
                  .orderBy('Time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No announcements yet.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;

                    final title = data['Title'] ?? '';
                    final info = data['Info'] ?? '';
                    final location = data['Location'] ?? '';
                    final picture = data['Picture'] ?? '';
                    final timeStart = data['Time'] as Timestamp?;
                    final timeEnd = data['EndTime'] as Timestamp?;

                    final timeLabel = timeEnd != null
                        ? "${_formatDate(timeStart)} → ${_formatDate(timeEnd)}"
                        : _formatDate(timeStart);

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16)),
                            const SizedBox(height: 6),
                            if (location.isNotEmpty)
                              Text("📍 $location",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            if (timeStart != null)
                              Text("🕒 $timeLabel",
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 6),
                            Text(info),
                            const SizedBox(height: 8),
                            if (picture.isNotEmpty &&
                                Uri.tryParse(picture)?.hasAbsolutePath ==
                                    true)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  picture,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const SizedBox(),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}