import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_poll_screen.dart';

class PollsSection extends StatelessWidget {
  const PollsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFF2E9E1);
    final Color cardColor = Colors.white;
    final Color borderColor = const Color(0xFFD6CFC7);
    final Color accentColor = const Color(0xFF22211F);
    final Color chipBg = const Color(0xFFF6F4F2);
    final Color submitBg = const Color(0xFF22211F);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text('Polls', style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Polls').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Center(child: Text('No polls yet.'));
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final title = data['Title'] ?? '';
                      final options = data.entries
                          .where((e) => e.key != 'Title' && e.key != 'Voters')
                          .toList();
                      final totalVotes = options.fold<int>(0, (prev, e) => prev + (e.value as int? ?? 0));

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor, width: 2),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ...options.map((e) {
                                final label = e.key;
                                final count = e.value ?? 0;
                                final percent = totalVotes > 0 ? ((count / totalVotes) * 100).toStringAsFixed(0) : '0';
                                return Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: chipBg,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          label,
                                          style: const TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                      Text(
                                        '$percent%',
                                        style: TextStyle(
                                          color: accentColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: submitBg,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePollScreen()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Create Poll',
      ),
    );
  }
}