import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CreateAdScreen extends StatefulWidget {
  const CreateAdScreen({super.key});

  @override
  State<CreateAdScreen> createState() => _CreateAdScreenState();
}

class _CreateAdScreenState extends State<CreateAdScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isUploading = false;

  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<void> _submitAd() async {
    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final imageUrl = _imageUrlController.text.trim();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      await _firestore.collection('ads').add({
        'advertiserId': _auth.currentUser!.uid,
        'title': title,
        'description': description,
        'imageUrl': imageUrl,
        'approved': false,
        'timestamp': Timestamp.now(),
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ad submitted! Awaiting approval.")),
      );
      _titleController.clear();
      _descController.clear();
      _imageUrlController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    setState(() => _isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Advertisement")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: "Ad Title"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: "Description"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: "Image URL (link)"),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _submitAd,
              icon: const Icon(Icons.post_add),
              label: Text(_isUploading ? "Posting..." : "Post Ad"),
            )
          ],
        ),
      ),
    );
  }
}
