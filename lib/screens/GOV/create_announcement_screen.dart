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
    DateTime? initialDateTime,
  }) async {
    final now = initialDateTime ?? DateTime.now();
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

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    final date = "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}";
    final time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    return "$date $time";
  }

  @override
  Widget build(BuildContext context) {
    final Color bgColor = const Color(0xFFE5E0DB);
    final Color cardColor = Colors.white;
    final Color borderColor = const Color(0xFFD6CFC7);
    final Color accentColor = const Color(0xFF22211F);
    final Color submitBg = const Color(0xFF22211F);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Create Announcement',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            // Card with form
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor, width: 2),
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title field: both Arabic and English in one box
                    TextField(
                      controller: _titleController,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Enter title... / ...أدخل العنوان',
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Image URL input only (no preview or arrow)
                    TextField(
                      controller: _imageUrlController,
                      decoration: InputDecoration(
                        hintText: 'Image URL...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 18),
                    // Start and End DateTime pickers with calendar icon
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _formatDateTime(_startDateTime),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Start date & time...',
                              prefixIcon: IconButton(
                                icon: Icon(Icons.calendar_today, color: accentColor),
                                onPressed: () async {
                                  await _pickDateTime(
                                    context: context,
                                    onPicked: (dateTime) {
                                      setState(() {
                                        _startDateTime = dateTime;
                                      });
                                    },
                                    initialDateTime: _startDateTime,
                                  );
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            readOnly: true,
                            controller: TextEditingController(
                              text: _formatDateTime(_endDateTime),
                            ),
                            decoration: InputDecoration(
                              hintText: 'End date & time...',
                              prefixIcon: IconButton(
                                icon: Icon(Icons.calendar_today, color: accentColor),
                                onPressed: () async {
                                  await _pickDateTime(
                                    context: context,
                                    onPicked: (dateTime) {
                                      setState(() {
                                        _endDateTime = dateTime;
                                      });
                                    },
                                    initialDateTime: _endDateTime,
                                  );
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Time & Date label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Time & Date",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        Text(
                          "الوقت والتاريخ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Location field
                    Row(
                      children: [
                        Icon(Icons.location_on, color: accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _locationController,
                            decoration: InputDecoration(
                              hintText: 'Location',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Description field: both Arabic and English in one box
                    TextField(
                      controller: _infoController,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'Description... / ...وصف',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        hintStyle: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Submit button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: submitBg,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                ),
                onPressed: _submit,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Submit",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                    SizedBox(width: 12),
                    Text(
                      "تقديم",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}