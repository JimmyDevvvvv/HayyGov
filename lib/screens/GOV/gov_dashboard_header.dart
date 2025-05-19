import 'package:flutter/material.dart';

class GovDashboardHeader extends StatelessWidget {
  final void Function(int)? onNav;
  const GovDashboardHeader({super.key, this.onNav});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          image: const DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.dstATop),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'HayyGov',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () => onNav?.call(1),
                  icon: const Icon(Icons.campaign, color: Colors.black45),
                  tooltip: 'Announcements',
                ),
                IconButton(
                  onPressed: () => onNav?.call(2),
                  icon: const Icon(Icons.poll, color: Colors.black45),
                  tooltip: 'Polls',
                ),
                IconButton(
                  onPressed: () => onNav?.call(3),
                  icon: const Icon(Icons.message, color: Colors.black45),
                  tooltip: 'Inbox',
                ),
                IconButton(
                  onPressed: () => onNav?.call(4),
                  icon: const Icon(Icons.phone, color: Colors.black45),
                  tooltip: 'Emergency',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
