import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/message.dart';

class AdminChatScreen extends StatefulWidget {
  final String userId;
  final String userRole;

  const AdminChatScreen({
    Key? key,
    required this.userId,
    required this.userRole,
  }) : super(key: key);

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
      print("❌ Error sending reply: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = _firestore
        .collection("chats")
        .doc(widget.userId)
        .collection("messages")
        .orderBy("timestamp", descending: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with ${widget.userRole}"),
      ),
      body: Column(
        children: [
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
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a reply...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendReply,
                  child: const Text("Send"),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
