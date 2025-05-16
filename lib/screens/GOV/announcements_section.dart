import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementsSection extends StatelessWidget {
  const AnnouncementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Announcements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Create'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => _AnnouncementCreateDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('Announcements').orderBy('Time', descending: true).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final docs = snapshot.data!.docs;
                  if (docs.isEmpty) return const Text('No announcements yet.');
                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      return Material(
                        child: ListTile(
                          title: Text(data['Title'] ?? ''),
                          subtitle: Text(data['Info'] ?? ''),
                          trailing: Text((data['Time'] as Timestamp).toDate().toLocal().toString().split(' ')[0]),
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
    );
  }
}

class _AnnouncementCreateDialog extends StatefulWidget {
  @override
  State<_AnnouncementCreateDialog> createState() => _AnnouncementCreateDialogState();
}

class _AnnouncementCreateDialogState extends State<_AnnouncementCreateDialog> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String info = '';
  String location = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Announcement'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (val) => title = val,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Info'),
              onChanged: (val) => info = val,
              validator: (val) => val == null || val.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Location'),
              onChanged: (val) => location = val,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await FirebaseFirestore.instance.collection('Announcements').add({
                'Title': title,
                'Info': info,
                'Location': location,
                'Picture': '',
                'Time': Timestamp.now(),
              });
              Navigator.pop(context);
            }
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
