import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_poll_screen.dart';
import 'announcement_feed_screen.dart';
import 'emergency_n.dart';
import '../report/report_list_screen.dart';

class PollsSection extends StatelessWidget {
  const PollsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFF2E9E1);
    final Color cardColor = Colors.white;
    final Color borderColor = const Color(0xFFD6CFC7);
    final Color accentColor = const Color(0xFF22211F);
    final Color chipBg = const Color(0xFFF6F4F2);
    final Color submitBg = const Color(0xFF22211F);
    final Color navBrown = const Color(0xFF9C7B4B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // --- HayyGov Header with background and navigation bar ---
            Container(
              margin: const EdgeInsets.fromLTRB(12, 18, 12, 0),
              decoration: BoxDecoration(
                color: navBrown, // Unified brown for header and navigator
                borderRadius: BorderRadius.circular(20),
                image: const DecorationImage(
                  image: AssetImage('assets/header_bg.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Color(0xFF9C7B4B), // Overlay with same brown
                    BlendMode.srcATop,
                  ),
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                    child: Column(
                      children: [
                        Center(
                          child: Text(
                            "HayyGov",
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black, // Black text for HayyGov
                              letterSpacing: 2,
                              shadows: [
                                Shadow(
                                  color: Colors.black12,
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // --- Navigator bar, same color as container ---
                        Container(
                          decoration: BoxDecoration(
                            color: navBrown, // Same brown as container
                            borderRadius: BorderRadius.circular(14),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Announcements
                              IconButton(
                                icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 32),
                                tooltip: 'Announcements',
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AnnouncementFeedScreen()),
                                  );
                                },
                              ),
                              // Polls (current)
                              IconButton(
                                icon: const Icon(Icons.poll, color: Colors.white, size: 32),
                                tooltip: 'Polls',
                                onPressed: () {},
                              ),
                              // Emergency
                              IconButton(
                                icon: const Icon(Icons.call, color: Colors.red, size: 32),
                                tooltip: 'Emergency',
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const EmergencyN()),
                                  );
                                },
                              ),
                              // Reports
                              IconButton(
                                icon: const Icon(Icons.description, color: Colors.white, size: 32),
                                tooltip: 'Reports',
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ReportListScreen()),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // --- Polls List ---
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Polls').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No polls yet.'));
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final title = data['Title'] ?? '';
                      final options = data.entries
                          .where((e) => e.key != 'Title' && e.key != 'Voters')
                          .toList();
                      final totalVotes = options.fold<int>(0, (prev, e) => prev + (e.value as int? ?? 0));

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: cardColor, // Use original color for poll cards
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
                              // Title row
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
                              // Choices
                              ...options.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final e = entry.value;
                                final label = e.key;
                                final count = e.value ?? 0;
                                final percent = totalVotes > 0 ? ((count / totalVotes) * 100).toStringAsFixed(0) : '0';
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 5),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEADCC8), // Match the color in the picture
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderColor, width: 1),
                                  ),
                                  child: Row(
                                    children: [
                                      // Remove the index if you want only the label and percent
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 15,
                                            color: Color(0xFF7C7672), // Softer gray-brown for text
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "$percent%",
                                        style: const TextStyle(
                                          color: Color(0xFF7C7672), // Softer gray-brown for percent
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: submitBg,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePollScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Create Poll',
      ),
    );
  }
}