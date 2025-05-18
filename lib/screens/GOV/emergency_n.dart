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
      backgroundColor: const Color(0xFFF2E9E1),
      body: Column(
        children: [
          const SizedBox(height: 30), // for status bar space
          // --- HayyGov Header with navigation bar (matching citizen_home_screen) ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  image: const AssetImage('assets/images/bg.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.4),
                    BlendMode.dstATop,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'HayyGov',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const AnnouncementFeedScreen()),
                          );
                        },
                        icon: const Icon(
                          Icons.campaign,
                          color: Colors.black45,
                        ),
                        tooltip: 'Announcements',
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.phone,
                          color: Colors.black,
                        ),
                        tooltip: 'Emergency',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const PollsSection()),
                          );
                        },
                        icon: const Icon(
                          Icons.poll,
                          color: Colors.black45,
                        ),
                        tooltip: 'Polls',
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const ReportListScreen()),
                          );
                        },
                        icon: const Icon(
                          Icons.report,
                          color: Colors.black45,
                        ),
                        tooltip: 'Reports',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // --- End HayyGov Header ---
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