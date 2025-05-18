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
                image: const DecorationImage(
                  image: AssetImage('assets/images/bg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black54,
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
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportListScreen()),
                          );
                        },
                        icon: const Icon(
                          Icons.report,
                          color: Colors.black45,
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