import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../GOV/announcement_feed_screen.dart';
import '../GOV/polls_section.dart';
import '../GOV/emergency_n.dart';
import '../messaging/admin_inbox_screen.dart';

class ReportListScreen extends StatefulWidget {
  const ReportListScreen({super.key});

  @override
  State<ReportListScreen> createState() => _ReportListScreenState();
}

class _ReportListScreenState extends State<ReportListScreen> {
  bool showInbox = false; // For the switch, false means we're on reports

  @override
  Widget build(BuildContext context) {
    final reportsRef = FirebaseFirestore.instance
        .collection('reports')
        .orderBy('timestamp', descending: true);

    final Color bgColor = const Color(0xFFF2E9E1);
    final Color navBrown = const Color(0xFF9C7B4B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("All Submitted Reports"),
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: bgColor,
      body: Column(
        children: [
          // --- HayyGov Header with navigation bar ---
          Container(
            margin: const EdgeInsets.fromLTRB(12, 18, 12, 0),
            decoration: BoxDecoration(
              color: navBrown,
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/header_bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xFF9C7B4B),
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
                            color: Colors.black,
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
                      Container(
                        decoration: BoxDecoration(
                          color: navBrown,
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
                            // Polls
                            IconButton(
                              icon: const Icon(Icons.poll, color: Colors.white, size: 32),
                              tooltip: 'Polls',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PollsSection()),
                                );
                              },
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
                            // Reports (current)
                            IconButton(
                              icon: const Icon(Icons.description, color: Colors.white, size: 32),
                              tooltip: 'Reports',
                              onPressed: () {},
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
          // --- Switch between Inbox and Reports ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: Container(
              width: 240,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Stack(
                children: [
                  AnimatedAlign(
                    alignment: showInbox ? Alignment.centerLeft : Alignment.centerRight,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 120,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBDBDBD),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Inbox icon always on the left
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!showInbox) {
                              setState(() {
                                showInbox = true;
                              });
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const AdminInboxScreen()),
                              );
                            }
                          },
                          child: Center(
                            child: Icon(
                              Icons.inbox,
                              color: showInbox ? Colors.white : Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      // Reports icon always on the right
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Already on Reports page, do nothing
                          },
                          child: Center(
                            child: Icon(
                              Icons.description,
                              color: showInbox ? Colors.black : Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // --- End Switch ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFD6CFC7), width: 2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row with title only (removed ! icon)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            content.length > 30
                                                ? "${content.substring(0, 30)}..."
                                                : content,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Submitted at: ${timestamp.toLocal()}",
                                            style: const TextStyle(
                                              color: Colors.grey,
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
                                if (imageUrl.isNotEmpty) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: AspectRatio(
                                      aspectRatio: 4 / 3,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.contain, // Show the whole image
                                        errorBuilder: (context, error, stackTrace) =>
                                            const SizedBox(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: const Color(0xFFD6CFC7)),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          content,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "From: $displayName",
                                  style: const TextStyle(fontSize: 13, color: Colors.black54),
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
          ),
        ],
      ),
    );
  }
}