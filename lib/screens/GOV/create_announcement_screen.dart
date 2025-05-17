import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateAnnouncementScreen extends StatefulWidget {
  const CreateAnnouncementScreen({super.key});

  @override
  State<CreateAnnouncementScreen> createState() =>
      _CreateAnnouncementScreenState();
}

class _CreateAnnouncementScreenState extends State<CreateAnnouncementScreen> {
  final _titleController = TextEditingController();
  final _infoController = TextEditingController();
  final _locationController = TextEditingController();
  final _imageUrlController = TextEditingController();

  DateTime? _startDateTime;
  DateTime? _endDateTime;

  Future<void> _pickDateTime({
    required BuildContext context,
    required Function(DateTime) onPicked,
    required String label,
  }) async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );
      if (pickedTime != null) {
        final fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        onPicked(fullDateTime);
      }
    }
  }

  Future<void> _submit() async {
    final title = _titleController.text.trim();
    final info = _infoController.text.trim();
    final location = _locationController.text.trim();
    final picture = _imageUrlController.text.trim();

    if (title.isEmpty ||
        info.isEmpty ||
        location.isEmpty ||
        picture.isEmpty ||
        _startDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields")),
      );
      return;
    }

    final data = {
      "Title": title,
      "Info": info,
      "Location": location,
      "Picture": picture,
      "Time": _startDateTime,
    };

    if (_endDateTime != null) {
      data["EndTime"] = _endDateTime;
    }

    try {
      await FirebaseFirestore.instance.collection("Announcements").add(data);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Announcement created")),
      );

      Navigator.pop(context);
    } catch (e) {
      print("🔥 Firestore write error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating announcement: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create Announcement")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _infoController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _imageUrlController,
              decoration: const InputDecoration(labelText: 'Image URL'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_startDateTime == null
                  ? "Pick Start Time"
                  : "Start: ${_startDateTime.toString()}"),
              onPressed: () => _pickDateTime(
                context: context,
                label: "Start Time",
                onPicked: (value) => setState(() => _startDateTime = value),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.access_time),
              label: Text(_endDateTime == null
                  ? "Pick End Time (optional)"
                  : "End: ${_endDateTime.toString()}"),
              onPressed: () => _pickDateTime(
                context: context,
                label: "End Time",
                onPicked: (value) => setState(() => _endDateTime = value),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.send),
              label: const Text("Submit"),
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}