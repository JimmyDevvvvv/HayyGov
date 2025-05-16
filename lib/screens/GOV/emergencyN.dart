import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/emergency_contact.dart';
import '../../services/firestore_service.dart';
import '../../widgets/contact_card.dart';

class EmergencyN extends StatefulWidget {
  const EmergencyN({super.key});

  @override
  State<EmergencyN> createState() => _EmergencyNState();
}

class _EmergencyNState extends State<EmergencyN> {
  final FirestoreService firestoreService = FirestoreService();
  final Uuid uuid = Uuid();
  List<EmergencyContact> _offlineContacts = [];

  @override
  void initState() {
    super.initState();
    _loadOfflineContacts();
  }

  void _loadOfflineContacts() async {
    final contacts = await firestoreService.getContactsOffline();
    setState(() {
      _offlineContacts = contacts;
    });
  }

  Future<void> _reloadContacts() async {
    // Reload contacts from Firestore and update UI
    final contacts = await firestoreService.getContacts();
    setState(() {
      _offlineContacts = contacts;
    });
  }

  void _addEmergencyContact() async {
    String name = '';
    String number = '';
    String iconUrl = '';

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Number'),
                keyboardType: TextInputType.phone,
                onChanged: (value) => number = value,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Icon URL'),
                keyboardType: TextInputType.url,
                onChanged: (value) => iconUrl = value,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final newContact = EmergencyContact(
                    id: uuid.v4(),
                    name: name,
                    number: number,
                    iconUrl: iconUrl,
                  );
                  await firestoreService.addContact(newContact);
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteEmergencyContact(EmergencyContact contact) async {
    await firestoreService.deleteContact(contact.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Numbers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFFD6C4B0),
      body: RefreshIndicator(
        onRefresh: _reloadContacts, // trigger reload when pulled
        child: StreamBuilder<List<EmergencyContact>>(
          stream: firestoreService.getContactsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                _offlineContacts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final contacts = snapshot.data ?? _offlineContacts;

            if (contacts.isEmpty) {
              return const Center(child: Text('No contacts available.'));
            }

            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return Dismissible(
                  key: Key(contact.id),
                  onDismissed: (direction) {
                    _deleteEmergencyContact(contact);
                  },
                  background: Container(color: Colors.red),
                  child: ContactCard(contact: contact),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEmergencyContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}