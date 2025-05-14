import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'create_announcement_screen.dart';
import 'create_poll_screen.dart';
import 'gov_emergency_screen.dart';

class GovernmentDashboardScreen extends StatelessWidget {
  const GovernmentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Government Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔗 Navigate to Emergency Numbers Page
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GovEmergencyScreen()),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text('View Emergency Numbers'),
              ),
            ),

            const SizedBox(height: 10),

            // 📣 Announcements
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Announcements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()),
                    );
                  },
                  child: const Text('Create ➕'),
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Announcements').orderBy('Time', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Text('No announcements yet.');
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return ListTile(
                      title: Text(data['Title'] ?? ''),
                      subtitle: Text(data['Info'] ?? ''),
                      trailing: Text((data['Time'] as Timestamp).toDate().toLocal().toString().split(' ')[0]),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 30),

            // 🗳 Polls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Polls', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreatePollScreen()),
                    );
                  },
                  child: const Text('Create ➕'),
                ),
              ],
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Polls').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Text('No polls yet.');
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final totalVotes = data.entries
                      .where((e) => e.key != 'Title' && e.key != 'Voters')
                      .fold<int>(0, (sum, e) => sum + (e.value as int? ?? 0));

                    return ListTile(
                      title: Text(data['Title'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: data.entries
                          .where((e) => e.key != 'Title' && e.key != 'Voters')
                          .map((e) {
                            final label = e.key;
                            final count = e.value ?? 0;
                            final percent = totalVotes > 0 ? ((count / totalVotes) * 100).toStringAsFixed(1) : '0';
                            return Text('$label — $count vote(s) | $percent%');
                          }).toList(),
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
