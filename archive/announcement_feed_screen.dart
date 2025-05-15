import 'package:flutter/material.dart';
import '../lib/models/announcement.dart';
import '../lib/services/announcement_service.dart';
import '../lib/screens/CIT/announcement_detail_screen.dart';

class AnnouncementFeedScreen extends StatelessWidget {
  final service = AnnouncementService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Announcements')),
      body: FutureBuilder<List<Announcement>>(
        future: service.getAnnouncements(),
        builder: (context, snapshot) {
          print("📡 snapshot.connectionState: ${snapshot.connectionState}");
          print("📡 snapshot.hasData: ${snapshot.hasData}");
          print("⚠️ snapshot.error: ${snapshot.error}");
          print("📦 snapshot.data: ${snapshot.data}");

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No announcements found.'));
          }

          final announcements = snapshot.data!;
          print("✅ Loaded ${announcements.length} announcements");

          return ListView.builder(
            itemCount: announcements.length,
            itemBuilder: (context, index) {
              final a = announcements[index];
              return ListTile(
                title: Text(a.title),
                subtitle: Text(a.location),
                trailing: Text('${a.timestamp.year}/${a.timestamp.month}/${a.timestamp.day}'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AnnouncementDetailScreen(announcement: a)),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
