// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Data model class for notification
class NotificationModel {
  final String id;
  final String userId;
  final String notification;
  final DateTime timestamp;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.notification,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['_id'] ?? '', // Default to empty string if null
      userId: json['userId'] ?? '', // Default to empty string if null
      notification: json['notification'] ?? '', // Default to empty string if null
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(), // Default to current date if timestamp is null
    );
  }
}

// The main widget page to display notifications
class NotificationPage extends StatefulWidget {
  final Map<String, String> userDetails;

  const NotificationPage({super.key, required this.userDetails});

  @override
  NotificationPageState createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  late Future<List<NotificationModel>> notifications;

  @override
  void initState() {
    super.initState();
    notifications = fetchNotifications(); // Fetch notifications when the page loads
  }

  // Function to fetch notifications from the backend
  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await http.get(Uri.parse('http://172.20.10.2:8080/notifications/user/67a8497370cec10c2abc19e5'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((notificationJson) => NotificationModel.fromJson(notificationJson))
            .toList();
      } else {
        throw Exception('Failed to load notifications. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print("Error: $e");
      throw Exception('Failed to load notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'My Notifications',
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
            ),
          ),
          const SizedBox(height: 20),
          // Using FutureBuilder to display notifications once they are fetched
          Expanded(
            child: FutureBuilder<List<NotificationModel>>(
              future: notifications, // Fetch notifications
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error fetching notifications'));
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No notifications found'));
                }

                // Notifications list (reversed to show new ones at the top)
                List<NotificationModel> notificationsList = snapshot.data!;
                notificationsList = notificationsList.reversed.toList();

                return ListView.builder(
                  itemCount: notificationsList.length,
                  itemBuilder: (context, index) {
                    var notification = notificationsList[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16),
                          title: Text(
                            notification.notification,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${notification.timestamp.toLocal()}',
                            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey.shade600),
                          ),
                          trailing: Icon(
                            Icons.notifications,
                            color: Colors.purple.shade700,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

