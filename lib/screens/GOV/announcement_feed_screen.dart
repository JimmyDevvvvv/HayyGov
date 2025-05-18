import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'create_announcement_screen.dart';

class AnnouncementFeedScreen extends StatelessWidget {
  const AnnouncementFeedScreen({super.key});

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy - h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final Color cardColor = Colors.white;
    final Color borderColor = const Color(0xFFD6CFC7);
    final Color accentColor = const Color(0xFF22211F);
    final Color bgColor = const Color(0xFFF2E9E1);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Announcements'),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
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

                    // Format date(s)
                    final startLabel = _formatDateTime(timeStart);
                    final endLabel = timeEnd != null ? _formatDateTime(timeEnd) : null;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor, width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row with icon and title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        endLabel == null
                                            ? "Date: $startLabel"
                                            : "Start: $startLabel\nEnd: $endLabel",
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Location row
                            if (location.isNotEmpty)
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.black54, size: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    location,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            if (location.isNotEmpty) const SizedBox(height: 12),
                            // Image and info row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (picture.isNotEmpty &&
                                    Uri.tryParse(picture)?.hasAbsolutePath == true)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      picture,
                                      height: 120,
                                      width: 160,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                          const SizedBox(width: 160, height: 120),
                                    ),
                                  ),
                                if (picture.isNotEmpty) const SizedBox(width: 16),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: borderColor),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      info,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                  ),
                                ),
                              ],
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
        backgroundColor: bgColor, // Match the background color
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black), // Use black icon for contrast
      ),
    );
  }
}