// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wordex_app/logoloading.dart';
import 'package:wordex_app/notifications.dart';
import 'package:wordex_app/profile.dart';
import 'package:wordex_app/quizhistory.dart';
import 'package:wordex_app/activities.dart';



class MyHome extends StatefulWidget {
  final Map<String, String> userDetails;

  const MyHome({super.key, required this.userDetails});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildHomePage(),
      Center(child: ActivitiesPage(userDetails: widget.userDetails)),
       NotificationPage(userDetails: widget.userDetails),
      Profile(userDetails: widget.userDetails),
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
          ),
          title: Text(
            'Hi, ${widget.userDetails['firstName']}',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Image.asset(
                  'assets/logoSmall.png',
                  height: 30,
                  width: 30,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.purple.shade50],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: pages[_currentIndex],
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.purple.shade200,
          backgroundColor: Colors.purple,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Activities'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }

Widget buildHomePage() {
  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),

                  image: DecorationImage(
  image: NetworkImage('https://firebasestorage.googleapis.com/v0/b/wordex-e1b46.firebasestorage.app/o/homebg.jpeg?alt=media&token=c7557d63-c1b3-4d24-a357-a0c7d5566476'),      fit: BoxFit.cover, // Ensures the image covers the entire container
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.5), // Dark overlay for better readability
        BlendMode.darken,
      ),
    ),
            ),
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Welcome to Worex', style: TextStyle(color: Colors.white70 , fontSize: 42, fontWeight: FontWeight.bold)),
                
                SizedBox(height: 30),
                Text('Wordex is a mobile app designed to identify dyslexia and provide effective solutions. Using the button below, you can take a test to check for signs of dyslexia and explore ways to overcome its challenges.',
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 18)),
                SizedBox(height: 20),
                Text('Click Below to get started with Diagnosis',
                    style: TextStyle(color: Colors.white70, fontSize: 16)),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoadingScreen(userDetails: widget.userDetails),
      ),
    );
  },
  icon: Icon(Icons.arrow_circle_right_outlined),
  label: Text('Start Test' , style: TextStyle(color: Colors.purple, fontSize: 20)),
),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text('Recommended for you', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                PaymentTile(title: 'Word Activities', icon: Icons.wordpress),
                PaymentTile(title: 'Reading Activities', icon: Icons.voice_chat),
                PaymentTile(title: 'Speling Activities', icon: Icons.music_note),
              ],
            ),
          ),
          SizedBox(height: 20),

          ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizHistory(userDetails: widget.userDetails),
      ),
    );
  },
  icon: Icon(Icons.view_agenda),
  label: Text('View all Previous Test Results'),
),

          SizedBox(height: 20),


          Text('Latest News', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                EventTile(title: 'Wordex New Software Update', date: 'March 15, 2024 - 10:00 AM', icon: Icons.event),
                EventTile(title: 'Wordex Rewards', date: 'April 5, 2024 - 2:00 PM', icon: Icons.event),
                EventTile(title: 'Tech Meetup', date: 'March 22, 2024 - 6:00 PM', icon: Icons.event),
                EventTile(title: 'Workshop', date: 'April 5, 2024 - 2:00 PM', icon: Icons.event),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

class PaymentTile extends StatelessWidget {
  final String title;
  final IconData icon;

  const PaymentTile({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.purple, size: 30),
            SizedBox(width: 100),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class EventTile extends StatelessWidget {
  final String title;
  final String date;
  final IconData icon;

  const EventTile({super.key, required this.title, required this.date, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: const EdgeInsets.symmetric(horizontal: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.purple, size: 30),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              date,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
