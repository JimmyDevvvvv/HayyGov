import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportFormScreen extends StatefulWidget {
  const ReportFormScreen({super.key});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final TextEditingController _reportController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isSubmitting = false;

  Future<void> _submitReport() async {
    final content = _reportController.text.trim();
    final imageUrl = _imageUrlController.text.trim();
    final location = _locationController.text.trim();
    if (content.isEmpty) return;

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated.")),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _firestore.collection('reports').add({
        'userId': userId,
        'content': content,
        'imageUrl': imageUrl,
        'location': location,
        'timestamp': Timestamp.now(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully!")),
      );
      _reportController.clear();
      _imageUrlController.clear();
      _locationController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD6C4B0),
      appBar: AppBar(
        title: const Text("Submit a Report"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text("Describe the issue you're facing:"),
            const SizedBox(height: 10),
            TextField(
              controller: _reportController,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "e.g. Water pipes are broken near 5th Street...",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Image URL (optional)",
                hintText: "Paste a link to an image",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: "Location (optional)",
                hintText: "e.g. 5th Street, near the park",
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submitReport,
              icon: const Icon(Icons.report),
              label: _isSubmitting
                  ? const Text("Submitting...")
                  : const Text("Submit Report"),
            )
          ],
        ),
      ),
    );
  }
}
