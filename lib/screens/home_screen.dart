import 'package:flutter/material.dart';
import '../models/emergency_contact.dart';
import '../services/firestore_service.dart';
import '../widgets/contact_card.dart';

class HomeScreen extends StatelessWidget {
  final FirestoreService firestoreService = FirestoreService();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6C4B0),
      appBar: AppBar(
        title: const Text('Emergency Numbers'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<EmergencyContact>>(
        future: firestoreService.getContacts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contacts available.'));
          }

          return ListView(
            children: snapshot.data!.map((contact) => ContactCard(contact: contact)).toList(),
          );
        },
      ),
    );
  }
}
