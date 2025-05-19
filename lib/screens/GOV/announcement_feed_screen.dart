import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'create_announcement_screen.dart';

class AnnouncementFeedScreen extends StatelessWidget {
  const AnnouncementFeedScreen({super.key});

  String _formatDateTime(Timestamp? timestamp) {
    if (timestamp == null) return '';
    final date = timestamp.toDate();
    return DateFormat('dd/MM/yyyy - h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFE5E0DB);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Announcements')
                  .orderBy('Time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('No announcements yet.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final id = docs[index].id;
                    final title = data['Title'] ?? '';
                    final info = data['Info'] ?? '';
                    final location = data['Location'] ?? '';
                    final picture = data['Picture'] ?? '';
                    final timestamp = data['Time'];
                    final endTime = data['EndTime'];

                    return Dismissible(
                      key: Key(id),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 24),
                        child: const Icon(Icons.delete, color: Colors.white, size: 32),
                      ),
                      secondaryBackground: Container(
                        color: Colors.blue,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const Icon(Icons.edit, color: Colors.white, size: 32),
                            const SizedBox(width: 8),
                            const Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Delete
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              title: Row(
                                children: const [
                                  Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                                  SizedBox(width: 8),
                                  Text('Delete Announcement'),
                                ],
                              ),
                              content: const Text(
                                'Are you sure you want to delete this announcement? This action cannot be undone.',
                                style: TextStyle(fontSize: 16),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  icon: const Icon(Icons.delete),
                                  label: const Text('Delete'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await FirebaseFirestore.instance.collection('Announcements').doc(id).delete();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Announcement deleted'), backgroundColor: Colors.red),
                            );
                          }
                          return confirm == true;
                        } else {
                          // Edit
                          await showDialog(
                            context: context,
                            builder: (ctx) {
                              final titleController = TextEditingController(text: title);
                              final infoController = TextEditingController(text: info);
                              final locationController = TextEditingController(text: location);
                              final imageController = TextEditingController(text: picture);
                              DateTime? startDate = timestamp != null ? (timestamp is Timestamp ? timestamp.toDate() : null) : null;
                              DateTime? endDate = endTime != null ? (endTime is Timestamp ? endTime.toDate() : null) : null;
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                    title: Row(
                                      children: const [
                                        Icon(Icons.edit, color: Colors.blue, size: 28),
                                        SizedBox(width: 8),
                                        Text('Edit Announcement'),
                                      ],
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextField(
                                            controller: titleController,
                                            decoration: const InputDecoration(
                                              labelText: 'Title',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: infoController,
                                            decoration: const InputDecoration(
                                              labelText: 'Info',
                                              border: OutlineInputBorder(),
                                            ),
                                            maxLines: 2,
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: locationController,
                                            decoration: const InputDecoration(
                                              labelText: 'Location',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          TextField(
                                            controller: imageController,
                                            decoration: const InputDecoration(
                                              labelText: 'Image URL',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            children: [
                                              const Text('Start:'),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    final picked = await showDatePicker(
                                                      context: context,
                                                      initialDate: startDate ?? DateTime.now(),
                                                      firstDate: DateTime(2020),
                                                      lastDate: DateTime(2100),
                                                    );
                                                    if (picked != null) {
                                                      setState(() => startDate = picked);
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.grey),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      startDate != null ? DateFormat('yyyy/MM/dd').format(startDate!) : 'Select date',
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              const Text('End:'),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () async {
                                                    final picked = await showDatePicker(
                                                      context: context,
                                                      initialDate: endDate ?? DateTime.now(),
                                                      firstDate: DateTime(2020),
                                                      lastDate: DateTime(2100),
                                                    );
                                                    if (picked != null) {
                                                      setState(() => endDate = picked);
                                                    }
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(color: Colors.grey),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Text(
                                                      endDate != null ? DateFormat('yyyy/MM/dd').format(endDate!) : 'Select date',
                                                      style: const TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
                                      ),
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                        onPressed: () async {
                                          await FirebaseFirestore.instance.collection('Announcements').doc(id).update({
                                            'Title': titleController.text.trim(),
                                            'Info': infoController.text.trim(),
                                            'Location': locationController.text.trim(),
                                            'Picture': imageController.text.trim(),
                                            if (startDate != null) 'Time': Timestamp.fromDate(startDate!),
                                            if (endDate != null) 'EndTime': Timestamp.fromDate(endDate!),
                                          });
                                          Navigator.pop(ctx);
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('Announcement updated'), backgroundColor: Colors.blue),
                                          );
                                        },
                                        icon: const Icon(Icons.save),
                                        label: const Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                          return false;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFD6CFC7), width: 2),
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
                                // Header row with icon and title (restored old design)
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            timestamp != null
                                                ? 'Date: ${_formatDateTime(timestamp)}'
                                                : 'Date: Not specified',
                                            style: TextStyle(
                                              color: Colors.grey[700],
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Location row
                                if (location.isNotEmpty)
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, color: Colors.black54, size: 18),
                                      const SizedBox(width: 4),
                                      Text(
                                        location,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                if (location.isNotEmpty) const SizedBox(height: 12),
                                // Image and info row
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (picture.isNotEmpty && Uri.tryParse(picture)?.hasAbsolutePath == true)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          picture,
                                          height: 120,
                                          width: 160,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => const SizedBox(width: 160, height: 120),
                                        ),
                                      ),
                                    if (picture.isNotEmpty) const SizedBox(width: 16),
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(color: const Color(0xFFD6CFC7)),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          info,
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (endTime != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'End: ${_formatDateTime(endTime)}',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
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
          backgroundColor: const Color(0xFF2c2c2c), // Match the background color
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreateAnnouncementScreen()),
            );
          },
          child: const Icon(Icons.add, color: Colors.white), // Use white icon for contrast
        ),
      );
  }
}