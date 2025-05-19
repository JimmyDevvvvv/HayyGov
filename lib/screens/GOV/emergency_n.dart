import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/emergency_contact.dart';
import '../../services/firestore_service.dart';
import '../../widgets/contact_card.dart';
import '../AD/ad_approval_screen.dart';

class EmergencyN extends StatefulWidget {
  const EmergencyN({super.key});

  @override
  State<EmergencyN> createState() => _EmergencyNState();
}

class _EmergencyNState extends State<EmergencyN> {
  final FirestoreService firestoreService = FirestoreService();
  final Uuid uuid = Uuid();
  List<EmergencyContact> _offlineContacts = [];

  bool showAds = false; // For the switch

  @override
  void initState() {
    super.initState();
    _loadOfflineContacts();
  }

  void _loadOfflineContacts() async {
    final contacts = await firestoreService.getContactsOffline();
    if (!mounted) return;
    setState(() {
      _offlineContacts = contacts;
    });
  }

  Future<void> _reloadContacts() async {
    final contacts = await firestoreService.getContacts();
    if (!mounted) return;
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
                  if (!context.mounted) return;
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
    if (!mounted) return;
    setState(() {});
  }

  void _toggleView(bool ads) {
    setState(() {
      showAds = ads;
    });
  }

  void _onHorizontalDrag(DragEndDetails details) {
    // Swipe left to go to AdApproval, right to go to Emergency Numbers
    if (details.primaryVelocity != null) {
      if (details.primaryVelocity! < -50) {
        _toggleView(true);
      } else if (details.primaryVelocity! > 50) {
        _toggleView(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFE5E0DB);
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // const GovDashboardHeader(), // Removed persistent header
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: _onHorizontalDrag,
                child: Column(
                  children: [
                    // --- Switch between Emergency Numbers and Ads Approval ---
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      child: Container(
                        width: 240,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Stack(
                          children: [
                            AnimatedAlign(
                              alignment: showAds ? Alignment.centerRight : Alignment.centerLeft,
                              duration: const Duration(milliseconds: 200),
                              child: Container(
                                width: 120,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBDBDBD),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _toggleView(false);
                                    },
                                    child: Center(
                                      child: Icon(
                                        Icons.call,
                                        color: !showAds ? Colors.white : Colors.black,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _toggleView(true);
                                    },
                                    child: Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        color: showAds ? Colors.white : Colors.green,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    // --- End Switch ---
                    Expanded(
                      child: showAds
                          ? const AdApprovalScreen()
                          : RefreshIndicator(
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF2c2c2c), // Match the background color
        onPressed: _addEmergencyContact,
        child: const Icon(Icons.add, color: Colors.white), // Use black icon for contrast
      ),
    );
  }
}