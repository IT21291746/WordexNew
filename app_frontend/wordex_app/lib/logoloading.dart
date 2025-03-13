// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:wordex_app/home.dart';
import 'package:wordex_app/quiz.dart';

class LoadingScreen extends StatefulWidget {
  final Map<String, String> userDetails;

  const LoadingScreen({super.key, required this.userDetails});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}


class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool showLoading = true;
  bool showMessage = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);

    // Start timer for 3 seconds to hide loading
    Timer(Duration(seconds: 3), () {
      setState(() {
        showLoading = false;
      });
      // Start exit animation
      Future.delayed(Duration(milliseconds: 500), () {
        setState(() {
          showMessage = true;
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: showLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -10 * (1 - _controller.value)),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/logoSmall.png',
                      height: 150,
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Wordex',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 20),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                  ),
                ],
              )
            : AnimatedOpacity(
                opacity: showMessage ? 1.0 : 0.0,
                duration: Duration(milliseconds: 500),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Welcome to Wordex Mobile',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'You are warmly welcome to Wordex mobile application which helps you ...',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'We are now ready to get you into the screening test to find whether you have difficulties in dyslexia.',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'As the first step, we are providing 5 IQ questions with answers. Each question has 30s to give an answer.',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'As the final step, we provide 20 questions to identify 4 types of dyslexia.',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
ElevatedButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHome(userDetails: widget.userDetails),
      ),
    );
  },
  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
  child: Text('Exit'),
),

                          SizedBox(width: 10),

ElevatedButton(
  onPressed: () {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Quiz(userDetails: widget.userDetails),
      ),
    );
  },
  style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 2, 185, 78)),
  child: Text('Continue'),
),
                          
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
