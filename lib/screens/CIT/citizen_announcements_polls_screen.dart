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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5E0DB),
      body: FutureBuilder<List<Announcement>>(
        future: announcementService.getAnnouncements(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final announcements = snapshot.data!;
          final userId = FirebaseAuth.instance.currentUser?.uid ?? '';

          return PrimaryScrollController(
            controller: _scrollController,
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('📣 Announcements',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                          if (polls.isEmpty) {
                            return const Text('No polls yet.');
                          }
                          final Color cardColor = Colors.white;
                          final Color borderColor = Color(0xFFD6CFC7);
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: polls.length,
                            itemBuilder: (context, index) {
                              final data = polls[index].data() as Map<String, dynamic>;
                              final pollId = polls[index].id;
                              final title = data['Title'] ?? '';
                              final voters = List<String>.from(data['Voters'] ?? []);
                              final hasVoted = voters.contains(userId);
                              final options = data.entries
                                  .where((e) => e.key != 'Title' && e.key != 'Voters')
                                  .toList();
                              final totalVotes = options.fold<int>(0, (prev, e) => prev + (e.value as int? ?? 0));
                              String? selectedOption;
                              return StatefulBuilder(
                                builder: (context, setPollState) {
                                  return Container(
                                    margin: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: cardColor,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: borderColor, width: 2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.03),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 14),
                                          if (!hasVoted) ...[
                                            ...options.asMap().entries.map((entry) {
                                              final label = entry.value.key;
                                              return Container(
                                                margin: const EdgeInsets.symmetric(vertical: 5),
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEADCC8),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: borderColor, width: 1),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: GestureDetector(
                                                        onTap: () => setPollState(() => selectedOption = label),
                                                        child: Row(
                                                          children: [
                                                            Radio<String>(
                                                              value: label,
                                                              groupValue: selectedOption,
                                                              onChanged: (val) => setPollState(() => selectedOption = val),
                                                              activeColor: Colors.brown,
                                                            ),
                                                            Flexible(
                                                              child: Text(
                                                                label,
                                                                style: const TextStyle(
                                                                  fontWeight: FontWeight.w600,
                                                                  fontSize: 15,
                                                                  color: Color(0xFF7C7672),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                            const SizedBox(height: 8),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: ElevatedButton(
                                                onPressed: selectedOption == null
                                                    ? null
                                                    : () async {
                                                        await FirebaseFirestore.instance
                                                            .collection('Polls')
                                                            .doc(pollId)
                                                            .update({
                                                          selectedOption!: FieldValue.increment(1),
                                                          'Voters': FieldValue.arrayUnion([userId]),
                                                        });
                                                        setPollState(() => selectedOption = null);
                                                      },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.brown,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                                ),
                                                child: const Text('Vote'),
                                              ),
                                            ),
                                          ] else ...[
                                            ...options.asMap().entries.map((entry) {
                                              final label = entry.value.key;
                                              final count = entry.value.value ?? 0;
                                              final percent = totalVotes > 0 ? ((count / totalVotes) * 100).toStringAsFixed(0) : '0';
                                              return Container(
                                                margin: const EdgeInsets.symmetric(vertical: 5),
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFEADCC8),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: borderColor, width: 1),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        label,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 15,
                                                          color: Color(0xFF7C7672),
                                                        ),
                                                    ),
                                                    ),
                                                    Text(
                                                      "$percent%",
                                                      style: const TextStyle(
                                                        color: Color(0xFF7C7672),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }),
                                            const SizedBox(height: 8),
                                            const Text(
                                              '✅ You’ve already voted',
                                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                            ),
                                          ],
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
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}