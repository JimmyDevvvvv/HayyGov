import 'package:flutter/material.dart';
import 'emergencyN.dart';

class GovernmentDashboardScreen extends StatefulWidget {
  const GovernmentDashboardScreen({super.key});

  @override
  State<GovernmentDashboardScreen> createState() => _GovernmentDashboardScreenState();
}

class _GovernmentDashboardScreenState extends State<GovernmentDashboardScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
  ];

  void _showAddEmergencyServiceModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Service Name'),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'URL Link'),
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Handle save action
                  Navigator.pop(context);
                },
                child: Text('Save'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Government Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddEmergencyServiceModal,
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.red,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.phone), label: 'Emergency'),
          // For now shows an error will be replaced (Placeholder)
          BottomNavigationBarItem(icon: Icon(Icons.campaign), label: 'Announcements'),
        ],
      ),
    );
  }
}
