import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String senderRole; // "citizen" or "advertiser"

  const ChatScreen({Key? key, required this.senderRole}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String get _uid => _auth.currentUser!.uid;

  Future<void> sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final message = Message(
      senderId: _uid,
      receiverId: "gov",
      text: text,
      timestamp: DateTime.now(),
    );

    final chatRef = _firestore.collection("chats").doc(_uid);

    try {
      // Store metadata
      await chatRef.set({
        'role': widget.senderRole,
        'lastMessage': text,
        'lastTimestamp': Timestamp.now(),
      });

      // Add message to subcollection
      await chatRef.collection("messages").add(message.toMap());

      _controller.clear();
    } catch (e) {
      print("❌ Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final messagesRef = _firestore
        .collection("chats")
        .doc(_uid)
        .collection("messages")
        .orderBy("timestamp", descending: false);

    return Scaffold(
      appBar: AppBar(
        title: Text("Chat with Gov"),
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
                    final isMe = msg.senderId == _uid;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue[200] : Colors.grey[300],
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
                      hintText: 'Enter your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: sendMessage,
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
