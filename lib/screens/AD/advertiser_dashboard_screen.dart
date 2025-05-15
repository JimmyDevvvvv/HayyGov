import 'package:flutter/material.dart';

class AdvertiserDashboardScreen extends StatelessWidget {
  const AdvertiserDashboardScreen({super.key}); // ✅ Const constructor added

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advertiser Dashboard'),
      ),
      body: const Center(
        child: Text('Welcome to the Advertiser Dashboard!'),
      ),
    );
  }
}
