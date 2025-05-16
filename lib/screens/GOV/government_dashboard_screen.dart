import 'package:flutter/material.dart';
import 'emergencyN.dart';
import '../messaging/admin_inbox_screen.dart'; // ✅ Make sure path is correct
import '../report/report_list_screen.dart'; // ✅ Make sure path is correct
import '../AD/ad_approval_screen.dart';
class GovernmentDashboardScreen extends StatefulWidget {
  const GovernmentDashboardScreen({super.key});

  @override
  State<GovernmentDashboardScreen> createState() => _GovernmentDashboardScreenState();
}

class _GovernmentDashboardScreenState extends State<GovernmentDashboardScreen> {
  int _currentIndex = 0;

final List<Widget> _screens = [
  HomeScreen(),
  const AdminInboxScreen(),
  const AdApprovalScreen(),
  const ReportListScreen(), // ✅ Add this line
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
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Emergency'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Inbox'), // ✅ Added
          BottomNavigationBarItem(icon: Icon(Icons.report_problem), label: 'Reports'),
          BottomNavigationBarItem(icon: Icon(Icons.verified), label: 'Approve Ads'),
          
        ],
      ),
    );
  }
}
