import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _infoController = TextEditingController();
  final _locationController = TextEditingController();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleController.text.trim();
    final info = _infoController.text.trim();
    final location = _locationController.text.trim();
    if (title.isEmpty || info.isEmpty || location.isEmpty) return;
    await FirebaseFirestore.instance.collection('Announcements').add({
      'Title': title,
      'Info': info,
      'Location': location,
      'Picture': '',
      'Time': Timestamp.now(),
    });
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Announcement')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _infoController,
                decoration: InputDecoration(labelText: 'Info'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
}
