import 'package:flutter/material.dart';
import 'emergency_n.dart';
import '../messaging/admin_inbox_screen.dart'; // ✅ Make sure path is correct
import '../report/report_list_screen.dart'; // ✅ Make sure path is correct
import '../AD/ad_approval_screen.dart';
import 'announcements_section.dart';
import 'polls_section.dart';

class GovernmentDashboardScreen extends StatefulWidget {
  const GovernmentDashboardScreen({super.key});

  @override
  State<GovernmentDashboardScreen> createState() => _GovernmentDashboardScreenState();
}

class _GovernmentDashboardScreenState extends State<GovernmentDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    GovMainScreen(), // Main combined screen (Announcements, Polls, Emergency)
    const AdminInboxScreen(),
    const ReportListScreen(),
    const AdApprovalScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HayyGov'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Main'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Inbox'),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.verified), label: 'Approve Ads'),
        ],
      ),
    );
  }
}

class GovMainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Announcements Section
            AnnouncementsSection(),
            const SizedBox(height: 24),
            // Polls Section
            PollsSection(),
            const SizedBox(height: 24),
            // Emergency Numbers Section
            EmergencyN(),
          ],
        ),
      ),
    );
  }
}
