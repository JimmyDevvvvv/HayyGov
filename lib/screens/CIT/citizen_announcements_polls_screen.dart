import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _pollsKey = GlobalKey();

  Future<String> _formatDateTime(DateTime? date) async {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy - h:mm a').format(date);
  }

  void _scrollToPolls() async {
    await Future.delayed(const Duration(milliseconds: 100));
    final ctx = _pollsKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 0xFFE5E0DB
      // 0xFFD6C4B0
      backgroundColor: const Color(0xFFE5E0DB),
      // appBar: AppBar(
      //   backgroundColor: Colors.brown,
      //   foregroundColor: Colors.white,
      //   elevation: 0,
      //   title: const Text('Citizen Announcements & Polls'),
      // ),
      body: FutureBuilder<List<Announcement>>(
        future: announcementService.getAnnouncements(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final announcements = snapshot.data!;
          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

          return ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('📣 Announcements',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _scrollToPolls,
                    icon: const Icon(Icons.poll, size: 18),
                    label: const Text('Go to Polls'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
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
                  child: FutureBuilder<String>(
                    future: _formatDateTime(announcement.timestamp),
                    builder: (context, snapshot) {
                      final dateLabel = snapshot.data ?? '';
                      final Color cardColor = Colors.white;
                      final Color borderColor = const Color(0xFFD6CFC7);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
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
                                  const Icon(Icons.warning_amber_rounded,
                                      color: Colors.amber, size: 28),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          announcement.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "Date: $dateLabel",
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
                              if (announcement.location.isNotEmpty)
                                Row(
                                  children: [
                                    const Icon(Icons.location_on,
                                        color: Colors.black54, size: 18),
                                    const SizedBox(width: 4),
                                    Text(
                                      announcement.location,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              if (announcement.location.isNotEmpty)
                                const SizedBox(height: 12),
                              // Image and info row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (announcement.picture.isNotEmpty &&
                                      Uri.tryParse(announcement.picture)?.hasAbsolutePath == true)
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        announcement.picture,
                                        height: 120,
                                        width: 160,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) =>
                                            const SizedBox(width: 160, height: 120),
                                      ),
                                    ),
                                  if (announcement.picture.isNotEmpty) const SizedBox(width: 16),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(color: borderColor),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        announcement.info,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
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
                    },
                  ),
                );
              }),
              const SizedBox(height: 24),
              SizedBox(
                key: _pollsKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🗳 Polls',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                                                        FieldValue.arrayUnion([userId]),
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
                                                            BorderRadius.circular(8),
                                                      ),
                                                    ),
                                                    Container(
                                                      width: barWidth,
                                                      height: 20,
                                                      decoration: BoxDecoration(
                                                        color: Colors.blue,
                                                        borderRadius:
                                                            BorderRadius.circular(8),
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
              ),
            ],
          );
        },
      ),
    );
  }
}