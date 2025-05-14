import 'package:flutter/material.dart';
import '../../models/emergency_contact.dart';
import '../../services/firestore_service.dart';
import '../../widgets/contact_card.dart';

class GovEmergencyScreen extends StatelessWidget {
  const GovEmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestoreService = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Numbers')),
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
              return ContactCard(contact: contacts[index]);
            },
          );
        },
      ),
    );
  }
}
