import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/announcement.dart';
import '../../services/announcement_service.dart';
import 'announcement_detail_screen.dart';

class CitizenAnnouncementsPollsScreen extends StatefulWidget {
  const CitizenAnnouncementsPollsScreen({super.key});

  @override
  State<CitizenAnnouncementsPollsScreen> createState() =>
      _CitizenAnnouncementsPollsScreenState();
}

class _CitizenAnnouncementsPollsScreenState
    extends State<CitizenAnnouncementsPollsScreen> {
  final announcementService = AnnouncementService();

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFD6C4B0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6C4B0),
        elevation: 0,
        title: const Text('Citizen Announcements & Polls'),
      ),
      body: FutureBuilder<List<Announcement>>(
        future: announcementService.getAnnouncements(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final announcements = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('📣 Announcements',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                ...announcements.map((announcement) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AnnouncementDetailScreen(
                            announcement: announcement,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(announcement.title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text("📍 ${announcement.location}"),
                          const SizedBox(height: 4),
                          Text(
                            "🕒 ${announcement.timestamp.year}/${announcement.timestamp.month}/${announcement.timestamp.day} "
                            "${announcement.timestamp.hour}:${announcement.timestamp.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AnnouncementDetailScreen(
                                        announcement: announcement),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.comment, size: 16),
                              label: const Text("Comment"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),
                const Text('🗳 Polls',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('Polls')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }
                    final polls = snapshot.data!.docs;

                    return Column(
                      children: polls.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final pollId = doc.id;
                        final title = data['Title'] ?? '';
                        final voters = List<String>.from(data['Voters'] ?? []);
                        final hasVoted = voters.contains(userId);

                        final entries = Map<String, int>.fromEntries(
                          data.entries
                              .where((e) =>
                                  e.key != 'Title' &&
                                  e.key != 'Voters' &&
                                  e.value is int)
                              .map((e) => MapEntry(e.key, e.value as int)),
                        );

                        final totalVotes =
                            entries.values.fold<int>(0, (a, b) => a + b);
                        String? selectedOption;

                        return StatefulBuilder(
                          builder: (context, setPollState) {
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  const SizedBox(height: 8),
                                  if (!hasVoted) ...[
                                    ...entries.keys.map((choice) {
                                      return RadioListTile<String>(
                                        title: Text(choice),
                                        value: choice,
                                        groupValue: selectedOption,
                                        onChanged: (val) => setPollState(
                                            () => selectedOption = val),
                                      );
                                    }),
                                    ElevatedButton(
                                      onPressed: selectedOption == null
                                          ? null
                                          : () async {
                                              await FirebaseFirestore.instance
                                                  .collection('Polls')
                                                  .doc(pollId)
                                                  .update({
                                                selectedOption!:
                                                    FieldValue.increment(1),
                                                'Voters':
                                                    FieldValue.arrayUnion(
                                                        [userId]),
                                              });
                                              setPollState(
                                                  () => selectedOption = null);
                                            },
                                      child: const Text("Vote"),
                                    ),
                                  ] else ...[
                                    const Text("✅ You’ve already voted",
                                        style: TextStyle(color: Colors.green)),
                                    const SizedBox(height: 8),
                                    ...entries.entries.map((entry) {
                                      final label = entry.key;
                                      final votes = entry.value;
                                      final percent = totalVotes > 0
                                          ? (votes / totalVotes * 100)
                                              .toStringAsFixed(1)
                                          : '0.0';
                                      final parsedPercent =
                                          double.tryParse(percent) ?? 0.0;
                                      final barWidth =
                                          MediaQuery.of(context).size.width *
                                              (parsedPercent / 100);

                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(label),
                                            Stack(
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.grey.shade300,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                Container(
                                                  width: barWidth,
                                                  height: 20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text('$percent%',
                                                style: const TextStyle(
                                                    fontSize: 12)),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
