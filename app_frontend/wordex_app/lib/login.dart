// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class MyLogin extends StatefulWidget {
  const MyLogin({super.key});

  @override
  State<MyLogin> createState() => _MyLoginState();
}

class _MyLoginState extends State<MyLogin> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage; // To show error messages

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

@override
void initState() {
  super.initState();
  _initializeNotifications();
}

void _initializeNotifications() {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  flutterLocalNotificationsPlugin.initialize(initializationSettings);
}


  Future<void> _login() async {
    final String userName = _usernameController.text.trim();
    final String password = _passwordController.text.trim();

    // Validate inputs
    if (userName.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage = 'Please fill in both username and password.';
      });
      return;
    }

    // API URL (Replace with your backend URL)
    final String apiUrl = 'http://172.20.10.2:8080/users/username/$userName';  // Adjusted to fetch user by username
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Compare passwords
if (data['password'] != null) {
  // Ensure password is a string before comparison
  if (data['password'].toString() == password) {
            await _sendNotification(data['id']);

Navigator.pushReplacementNamed(
  context,
  'home',
  arguments: {
    'id': data['id']?.toString() ?? '',
    'firstName': data['firstName']?.toString() ?? '',
    'lastName': data['lastName']?.toString() ?? '',
    'email': data['email']?.toString() ?? '',
    'birthDate': data['birthDate']?.toString() ?? '',
    'mobileNumber': data['mobileNumber']?.toString() ?? '',
    'userName': userName,
    'password': password,
  },
);

  } else {
    setState(() {
      _errorMessage = 'Invalid username or password.';
    });
  }
}else {
          setState(() {
            _errorMessage = 'Invalid username or password.';
          });
        }
      } else if (response.statusCode == 404) {
        // User not found
        setState(() {
          _errorMessage = 'User not found.';
        });
      } else {
        setState(() {
          _errorMessage = 'Something went wrong. Please try again later.';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to connect to the server: $error';
      });
    }
  }

Future<void> _sendNotification(String id) async {
  final String notificationApiUrl = 'http://172.20.10.2:8080/notifications';

  final Map<String, dynamic> notificationData = {
    'userId': id,
    'notification': 'You have successfully logged in.',
  };

  try {
    final response = await http.post(
      Uri.parse(notificationApiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(notificationData),
    );

    if (response.statusCode == 201) {
      print('Notification saved successfully');
      
      // Show local notification
      _showLocalNotification("Login Successful", "You have successfully logged in.");
    } else {
      print('Failed to save notification: ${response.body}');
    }
  } catch (error) {
    print('Error sending notification: $error');
  }
}

Future<void> _showLocalNotification(String title, String body) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'login_channel', // Unique ID for this type of notification
    'Login Notifications', // Name of the notification channel
    importance: Importance.high,
    priority: Priority.high,
  );

  const NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  await flutterLocalNotificationsPlugin.show(
    0, // Notification ID
    title,
    body,
    platformChannelSpecifics,
  );
}



  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/login_bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Semi-transparent overlay
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
            // WordeX Title
            Positioned(
              top: 49,
              left: MediaQuery.of(context).size.width * 0.25,
              child: Text(
                'WordeX',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 65,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Caveat',
                ),
              ),
            ),
            // Logo Image
            Positioned(
              top: 130,
              left: MediaQuery.of(context).size.width * 0.17,
              child: Image.asset(
                'assets/logo.png',
                height: 250,
                width: 250,
              ),
            ),
            // Login Form
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 320),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                      margin: EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Welcome Back!',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Username Field
                          TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.email),
                              hintText: "User Name",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Password Field
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                'Forgot Password',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                          const SizedBox(height: 04),
                          // Login Button
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 15),
                          // Signup Text
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Don't have an account? "),
                              GestureDetector(
                                onTap: () {
                                  // Navigate to Signup page
                                  Navigator.pushNamed(context, 'signup'); // Replace with your route
                                },
                                child: Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
