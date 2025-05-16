import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_chat_screen.dart';

class AdminInboxScreen extends StatelessWidget {
  const AdminInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatStream = FirebaseFirestore.instance
        .collection('chats')
        .orderBy('lastTimestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Inbox - All Messages"),
      ),
      body: StreamBuilder<QuerySnapshot>(
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

        return ListTile(
          leading: Icon(role == "citizen" ? Icons.person : Icons.business),
          title: Text("From: $displayName"),
          subtitle: Text("$role - $lastMessage"),
          trailing: Text(
            "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}",
            style: const TextStyle(fontSize: 12),
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
        );
      },
    );
  },
);
        },
      ),
    );
  }
}
