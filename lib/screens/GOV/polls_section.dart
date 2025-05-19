import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_poll_screen.dart';

class PollsSection extends StatelessWidget {
  const PollsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFE5E0DB);
    final Color cardColor = Colors.white;
    final Color borderColor = const Color(0xFFD6CFC7);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // const SizedBox(height: 30), // for status bar space
          // const GovDashboardHeader(), // Removed persistent header
          // --- Polls List ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('Polls').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No polls yet.'));
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = data['Title'] ?? '';
                    final options = data.entries
                        .where((e) => e.key != 'Title' && e.key != 'Voters')
                        .toList();
                    final totalVotes = options.fold<int>(0, (prev, e) => prev + (e.value as int? ?? 0));

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title row
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            // Choices
                            ...options.asMap().entries.map((entry) {
                              final label = entry.value.key;
                              final count = entry.value.value ?? 0;
                              final percent = totalVotes > 0 ? ((count / totalVotes) * 100).toStringAsFixed(0) : '0';
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEADCC8),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: borderColor, width: 1),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                          color: Color(0xFF7C7672),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "$percent%",
                                      style: const TextStyle(
                                        color: Color(0xFF7C7672),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2c2c2c),
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