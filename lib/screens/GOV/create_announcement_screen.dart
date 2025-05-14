import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() => _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String info = '';
  String location = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    await FirebaseFirestore.instance.collection('Announcements').add({
      'Title': title,
      'Info': info,
      'Location': location,
      'Picture': '',
      'Time': Timestamp.now(),
    });

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
                decoration: InputDecoration(labelText: 'Title'),
                onSaved: (val) => title = val ?? '',
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Info'),
                onSaved: (val) => info = val ?? '',
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Location'),
                onSaved: (val) => location = val ?? '',
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
