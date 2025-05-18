import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';
import '../GOV/announcement_feed_screen.dart';
import '../GOV/polls_section.dart';
import '../GOV/emergency_n.dart';
import '../report/report_list_screen.dart';

class AdminChatScreen extends StatefulWidget {
  final String userId;
  final String userRole;

  const AdminChatScreen({super.key, required this.userId, required this.userRole});

  @override
  State<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends State<AdminChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final _firestore = FirebaseFirestore.instance;

  final String adminId = "gov"; // gov is always the sender from admin side

  Future<void> sendReply() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = Message(
      senderId: adminId,
      receiverId: widget.userId,
      text: text,
      timestamp: DateTime.now(),
    );

    final chatRef = _firestore.collection("chats").doc(widget.userId);

    try {
      // Update metadata
      await chatRef.set({
        'role': widget.userRole,
        'lastMessage': text,
        'lastTimestamp': Timestamp.now(),
      }, SetOptions(merge: true));

      // Add the message to the thread
      await chatRef.collection("messages").add(message.toMap());

      _controller.clear();
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = _firestore
        .collection("chats")
        .doc(widget.userId)
        .collection("messages")
        .orderBy("timestamp", descending: false);

    final Color bgColor = const Color(0xFFF2E9E1);
    final Color navBrown = const Color(0xFF9C7B4B);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.userRole}"),
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
          // --- End HayyGov Header ---
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: messagesRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final msg = Message.fromMap(docs[index].data() as Map<String, dynamic>);
                    final isAdmin = msg.senderId == adminId;

                    return Align(
                      alignment: isAdmin ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isAdmin ? Colors.green[200] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(msg.text),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD6CFC7), width: 2),
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'Type a reply...',
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C7B4B),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: sendReply,
                      tooltip: "Send",
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}