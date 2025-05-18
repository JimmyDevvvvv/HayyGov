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

  void _navigateToInbox(BuildContext context) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 350),
        pageBuilder: (_, __, ___) => const AdminInboxScreen(),
        transitionsBuilder: (_, animation, __, child) {
          final offsetAnimation = Tween<Offset>(
            begin: const Offset(-1.0, 0.0), // Slide from left
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
          return SlideTransition(position: offsetAnimation, child: child);
        },
      ),
    );
  }

  void _onHorizontalDrag(DragEndDetails details) {
    // Swipe right to go to Inbox
    if (details.primaryVelocity != null && details.primaryVelocity! > 50) {
      _navigateToInbox(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportsRef = FirebaseFirestore.instance
        .collection('reports')
        .orderBy('timestamp', descending: true);

    final Color bgColor = const Color(0xFFF2E9E1);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          const SizedBox(height: 30), // for status bar space
          // --- HayyGov Header with navigation bar (matching citizen_home_screen) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: const AssetImage('assets/images/bg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'HayyGov',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const AnnouncementFeedScreen()),
                          );
                        },
                        icon: const Icon(
                          Icons.campaign,
                          color: Colors.black45,
                        ),
                        tooltip: 'Announcements',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const EmergencyN()),
                          );
                        },
                        icon: const Icon(
                          Icons.phone,
                          color: Colors.black45,
                        ),
                        tooltip: 'Emergency',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const PollsSection()),
                          );
                        },
                        icon: const Icon(
                          Icons.poll,
                          color: Colors.black45,
                        ),
                        tooltip: 'Polls',
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.report,
                          color: Colors.black,
                        ),
                        tooltip: 'Reports',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // --- End HayyGov Header ---
          // --- Switch between Inbox and Reports ---
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18.0),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: _onHorizontalDrag,
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
                                _navigateToInbox(context);
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