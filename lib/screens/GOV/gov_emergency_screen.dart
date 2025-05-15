import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../../models/emergency_contact.dart';
import '../../services/firestore_service.dart';
import '../../widgets/contact_card.dart';

class GovEmergencyScreen extends StatefulWidget {
  const GovEmergencyScreen({super.key});

  @override
  State<GovEmergencyScreen> createState() => _GovEmergencyScreenState();
}

class _GovEmergencyScreenState extends State<GovEmergencyScreen> {
  final firestoreService = FirestoreService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  final TextEditingController iconController = TextEditingController();

  Future<void> _showAddContactDialog() async {
    nameController.clear();
    numberController.clear();
    iconController.clear();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Emergency Contact'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: numberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: iconController,
                decoration: const InputDecoration(labelText: 'Icon URL'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          ElevatedButton(
            child: const Text('Save'),
            onPressed: () async {
              final name = nameController.text.trim();
              final number = numberController.text.trim();
              final icon = iconController.text.trim();

              if (name.isEmpty || number.isEmpty || icon.isEmpty) return;

              final contact = EmergencyContact(
                id: const Uuid().v4(),
                name: name,
                number: number,
                iconUrl: icon,
              );

              await firestoreService.addContact(contact);
              Navigator.pop(ctx);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmDeleteDialog() async {
    return await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Deletion"),
        content: const Text("Are you sure you want to delete this contact?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          ElevatedButton(
            child: const Text("Delete"),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    ) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Numbers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Contact',
            onPressed: _showAddContactDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<EmergencyContact>>(
        future: firestoreService.getContacts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final contacts = snapshot.data!;
          if (contacts.isEmpty) return const Center(child: Text('No emergency contacts found.'));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];

              return Dismissible(
                key: Key(contact.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                confirmDismiss: (direction) => _confirmDeleteDialog(),
                onDismissed: (direction) async {
                  await firestoreService.deleteContact(contact.id);
                  setState(() {});
                },
                child: ContactCard(contact: contact),
              );
            },
          );
        },
      ),
    );
  }
}
