// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class ActivitiesPage extends StatelessWidget {
  final Map<String, String> userDetails;

  const ActivitiesPage({super.key, required this.userDetails});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ActivityTile(
              title: 'Recommended Activities',
              icon: Icons.star_border,
              onTap: () {
                // Navigate to Recommended Activities Page (Create this page later)
              },
            ),
            ActivityTile(
              title: 'Results',
              icon: Icons.assessment,
              onTap: () {
                // Navigate to Results Page (Create this page later)
              },
            ),
            ActivityTile(
              title: 'Fun Games',
              icon: Icons.videogame_asset,
              onTap: () {
                // Navigate to Fun Games Page (Create this page later)
              },
            ),
          ],
        ),
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const ActivityTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.purple, size: 30),
            const SizedBox(width: 20),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
