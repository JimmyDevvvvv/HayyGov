import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CitizenAnnouncementsPollsScreen extends StatelessWidget {
  const CitizenAnnouncementsPollsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6C4B0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFD6C4B0),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Icon(Icons.home, size: 30),
            Icon(Icons.warning_amber, size: 30),
            Icon(Icons.phone, size: 30),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📣 ANNOUNCEMENTS
            const Text('📢 Announcements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Announcements')
                  .orderBy('Time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Text('No announcements available.');

                return ListView.builder(
                  itemCount: docs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final date = (data['Time'] as Timestamp?)?.toDate();
                    final title = data['Title'] ?? 'No title';
                    final info = data['Info'] ?? 'No info';
                    final location = data['Location'] ?? 'No location';

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.warning, color: Colors.orange),
                                SizedBox(width: 8),
                                Text("Water Pipe Maintenance", style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(info),
                            const SizedBox(height: 4),
                            Text("Date: ${date?.toLocal().toString().split(' ').first ?? 'Unknown'}"),
                            Text("Time: ${date != null ? "${date.hour} AM - ${date.hour + 2} AM" : ''}"),
                            Text("📍 $location"),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Comment...",
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.add_circle, color: Colors.black),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // 🗳 POLLS
            const Text('🗳 Polls', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Polls').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Text('No polls available.');

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['Title'] ?? 'Poll';
                    final votes = Map.from(data)..removeWhere((k, v) => k == 'Title' || k == 'Voters');
                    final totalVotes = votes.values.fold<int>(0, (sum, v) => sum + (v as int? ?? 0));

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            ...votes.entries.map((entry) {
                              final label = entry.key;
                              final count = entry.value ?? 0;
                              final percent = totalVotes > 0 ? (count / totalVotes * 100).toStringAsFixed(1) : '0';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(child: Text(label)),
                                    const SizedBox(width: 8),
                                    Text("$percent%"),
                                  ],
                                ),
                              );
                            }).toList(),
                            const SizedBox(height: 8),
                            Center(
                              child: ElevatedButton(
                                onPressed: () {},
                                child: const Text("Vote"),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
