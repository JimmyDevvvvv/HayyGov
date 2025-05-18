import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_chat_screen.dart';
import '../GOV/announcement_feed_screen.dart';
import '../GOV/polls_section.dart';
import '../GOV/emergency_n.dart';
import '../report/report_list_screen.dart';

class AdminInboxScreen extends StatefulWidget {
  const AdminInboxScreen({super.key});

  @override
  State<AdminInboxScreen> createState() => _AdminInboxScreenState();
}

class _AdminInboxScreenState extends State<AdminInboxScreen> {
  bool showInbox = true; // For the switch

  @override
  Widget build(BuildContext context) {
    final chatStream = FirebaseFirestore.instance
        .collection('chats')
        .orderBy('lastTimestamp', descending: true)
        .snapshots();

    final Color bgColor = const Color(0xFFF2E9E1);
    final Color navBrown = const Color(0xFF9C7B4B);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inbox - All Messages"),
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
                            // Already on Inbox page, do nothing
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
                            if (showInbox) {
                              setState(() {
                                showInbox = false;
                              });
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const ReportListScreen()),
                              );
                            }
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
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text("No messages yet."));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final senderId = docs[index].id;
                    final role = data['role'] ?? 'unknown';
                    final lastMessage = data['lastMessage'] ?? '';
                    final timestamp = (data['lastTimestamp'] as Timestamp).toDate();

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(senderId).get(),
                      builder: (context, userSnapshot) {
                        String displayName = senderId;
                        if (userSnapshot.connectionState == ConnectionState.done && userSnapshot.hasData) {
                          final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                          if (userData != null && userData.containsKey('email')) {
                            displayName = userData['email'];
                          }
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFD6CFC7), width: 2),
                          ),
                          child: ListTile(
                            leading: Icon(
                              role == "citizen" ? Icons.person : Icons.business,
                              color: navBrown,
                              size: 32,
                            ),
                            title: Text(
                              "From: $displayName",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "$role - $lastMessage",
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminChatScreen(
                                    userId: senderId,
                                    userRole: role,
                                  ),
                                ),
                              );
                            },
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