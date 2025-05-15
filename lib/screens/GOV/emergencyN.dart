import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/emergency_contact.dart';
import '../../services/firestore_service.dart';
import '../../widgets/contact_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
                decoration: const InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Number'),
                keyboardType: TextInputType.phone,
                onChanged: (value) => number = value,
              ),
              TextField(
                decoration: const InputDecoration(labelText: 'Icon URL'),
                keyboardType: TextInputType.url,
                onChanged: (value) => iconUrl = value,
              ),
              const SizedBox(height: 16),
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
                  _reloadContacts(); // ✅ Refresh after adding
                },
                child: const Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteEmergencyContact(EmergencyContact contact) async {
    await firestoreService.deleteContact(contact.id); // ✅ Fixed: pass ID
    _reloadContacts(); // ✅ Refresh after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6C4B0),
      body: RefreshIndicator(
        onRefresh: _reloadContacts,
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
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    color: Colors.red,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    _deleteEmergencyContact(contact);
                  },
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
