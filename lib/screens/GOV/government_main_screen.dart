import 'package:flutter/material.dart';
import 'polls_section.dart';
import 'emergency_n.dart';
import '../messaging/admin_inbox_screen.dart';
import '../report/report_list_screen.dart';
import '../AD/ad_approval_screen.dart';
import 'announcement_feed_screen.dart';

class GovernmentMainScreen extends StatefulWidget {
  const GovernmentMainScreen({super.key});

  @override
  State<GovernmentMainScreen> createState() => _GovernmentMainScreenState();
}

class _GovernmentMainScreenState extends State<GovernmentMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    _GovDashboard(), // Main dashboard with navigation tiles
    AdminInboxScreen(),
    ReportListScreen(),
    AdApprovalScreen(),
  ];

  void _navigateTo(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HayyGov')),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateTo,
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

class _GovDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final parentState = context.findAncestorStateOfType<_GovernmentMainScreenState>();
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        ListTile(
          leading: const Icon(Icons.announcement),
          title: const Text('Announcements'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => AnnouncementFeedScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.poll),
          title: const Text('Polls'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PollsSection()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.phone),
          title: const Text('Emergency Numbers'),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EmergencyN()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.message),
          title: const Text('Inbox'),
          onTap: () => parentState?._navigateTo(1),
        ),
        ListTile(
          leading: const Icon(Icons.report_problem),
          title: const Text('Reports'),
          onTap: () => parentState?._navigateTo(2),
        ),
        ListTile(
          leading: const Icon(Icons.verified),
          title: const Text('Approve Ads'),
          onTap: () => parentState?._navigateTo(3),
        ),
      ],
    );
  }
}
