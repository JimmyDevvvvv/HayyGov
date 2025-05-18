import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../models/emergency_contact.dart';
import '../../services/firestore_service.dart';
import '../../widgets/contact_card.dart';
import 'announcement_feed_screen.dart';
import 'polls_section.dart';
import '../report/report_list_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    final Color navBrown = const Color(0xFF9C7B4B);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Numbers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: const Color(0xFFD6C4B0),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: const Color(0xFFD6C4B0),
      body: Column(
        children: [
          // --- HayyGov Header with navigation bar ---
          Container(
            margin: const EdgeInsets.fromLTRB(12, 18, 12, 0),
            decoration: BoxDecoration(
              color: navBrown,
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: AssetImage('assets/header_bg.jpg'),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Color(0xFF9C7B4B),
                  BlendMode.srcATop,
                ),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.13),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
                  child: Column(
                    children: [
                      Center(
                        child: Text(
                          "HayyGov",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2,
                            shadows: [
                              Shadow(
                                color: Colors.black12,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: navBrown,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Announcements
                            IconButton(
                              icon: const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 32),
                              tooltip: 'Announcements',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AnnouncementFeedScreen()),
                                );
                              },
                            ),
                            // Polls
                            IconButton(
                              icon: const Icon(Icons.poll, color: Colors.white, size: 32),
                              tooltip: 'Polls',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const PollsSection()),
                                );
                              },
                            ),
                            // Emergency (current)
                            IconButton(
                              icon: const Icon(Icons.call, color: Colors.red, size: 32),
                              tooltip: 'Emergency',
                              onPressed: () {},
                            ),
                            // Reports
                            IconButton(
                              icon: const Icon(Icons.description, color: Colors.white, size: 32),
                              tooltip: 'Reports',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (_) => const ReportListScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
                            // Do nothing, already on Emergency page
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
                            // Navigate to AdApprovalScreen when pressing the right side
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const AdApprovalScreen()),
                            );
                          },
                          child: Center(
                            child: Icon(
                              Icons.check_circle,
                              color: !showAds ? Colors.green : Colors.white, // Green when not selected
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
            child: RefreshIndicator(
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
      floatingActionButton: FloatingActionButton(
        onPressed: _addEmergencyContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}