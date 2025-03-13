// ignore_for_file: use_build_context_synchronously, deprecated_member_use, avoid_print, unused_field

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MySignup extends StatefulWidget {
  const MySignup({super.key});

  @override
  State<MySignup> createState() => _MySignupState();
}

class _MySignupState extends State<MySignup> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  String? _successMessage;
  String? _usernameErrorMessage;

  @override
  void initState() {
    super.initState();

    _usernameController.addListener(() {
      String currentText = _usernameController.text;
      if (currentText != currentText.toUpperCase()) {
        _usernameController.value = _usernameController.value.copyWith(
          text: currentText.toUpperCase(),
          selection: TextSelection.collapsed(offset: currentText.length),
        );
      }

      if (currentText.isNotEmpty) {
        _checkUsernameExistence(currentText);
      } else {
        setState(() {
          _usernameErrorMessage = null;
        });
      }
    });
  }

  Future<void> _checkUsernameExistence(String username) async {
    final String apiUrl = 'http://172.20.10.2:8080/users/checkUsername';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': username}),
      );

      if (response.statusCode == 200) {
        final responseBody = response.body;
        if (responseBody == 'Username is already taken') {
          setState(() {
            _usernameErrorMessage = 'Username is already taken. Please choose another.';
          });
        } else {
          setState(() {
            _usernameErrorMessage = null;
          });
        }
      } else {
        setState(() {
          _usernameErrorMessage = 'Error checking username.';
        });
      }
    } catch (error) {
      setState(() {
        _usernameErrorMessage = 'Error checking username: $error';
      });
    }
  }

  Future<void> _signup() async {
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();
    final String birthDate = _birthDateController.text.trim();
    final String mobileNumber = _mobileNumberController.text.trim();
    final String email = _emailController.text.trim();
    final String username = _usernameController.text.trim().toUpperCase();
    final String password = _passwordController.text.trim();

    if ([firstName, lastName, birthDate, mobileNumber, email, username, password]
        .any((field) => field.isEmpty)) {
      setState(() {
        _errorMessage = 'Please fill in all fields.';
      });
      return;
    }

    if (mobileNumber.length < 10) {
      setState(() {
        _errorMessage = 'Mobile number must be at least 10 digits.';
      });
      return;
    }

    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(email)) {
      setState(() {
        _errorMessage = 'Please enter a valid email address.';
      });
      return;
    }

    if (username.length < 6 || username.length > 8) {
      setState(() {
        _errorMessage = 'Username must be between 6 and 8 characters.';
      });
      return;
    }

    if (_usernameErrorMessage != null) {
      setState(() {
        _errorMessage = _usernameErrorMessage;
      });
      return;
    }

    final String apiUrl = 'http://172.20.10.2:8080/users/checkUsername';

    final Map<String, String> user = {
      'firstName': firstName,
      'lastName': lastName,
      'birthDate': birthDate,
      'mobileNumber': mobileNumber,
      'email': email,
      'userName': username,
      'password': password,
    };

    try {
      final usernameResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userName': username}),
      );

      if (usernameResponse.statusCode == 200 && usernameResponse.body == 'false') {
        setState(() {
          _errorMessage = 'Username is already taken. Please choose another.';
        });
        return;
      }

      final passwordRegExp = RegExp(
          r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[!@#\$%\^&\*])[A-Za-z\d!@#\$%\^&\*]{6,12}$');
      if (!passwordRegExp.hasMatch(password)) {
        setState(() {
          _errorMessage = 'Password must be 6-12 characters with at least 1 uppercase, 1 lowercase, 1 number, and 1 special character.';
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://172.20.10.2:8080/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user),
      );

      if (response.statusCode == 201) {
        setState(() {
          _successMessage = 'Account created successfully!';
          _errorMessage = null;
        });

        await _sendWelcomeEmail(firstName, lastName, email);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Sign Up Successful'),
              content: Text('Your account has been created successfully. Press OK to continue to the home page.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, 'login');
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        setState(() {
          _errorMessage = 'Failed to create account. Please try again.';
          _successMessage = null;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Failed to connect to the server. : $error';
        _successMessage = null;
      });
    }
  }

  Future<void> _sendWelcomeEmail(String firstName, String lastName, String email) async {
    final String emailApiUrl = 'http://172.20.10.2:8080/sendWelcomeEmail';

    final Map<String, String> emailData = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
    };

    try {
      final response = await http.post(
        Uri.parse(emailApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(emailData),
      );

      if (response.statusCode == 200) {
        print('Welcome email sent successfully!');
      } else {
        print('Failed to send welcome email.');
      }
    } catch (error) {
      print('Error sending email: $error');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _birthDateController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
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
            Container(
              color: Colors.black.withOpacity(0.3),
            ),
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
            Positioned(
              top: 130,
              left: MediaQuery.of(context).size.width * 0.17,
              child: Image.asset(
                'assets/logo.png',
                height: 250,
                width: 250,
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 300),
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
                            'Create New Account',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Your existing signup form code here (same as previous, just updated with the new text)
                          _buildTextField("First Name", _firstNameController),
                          _buildTextField("Last Name", _lastNameController),
                          _buildDateField("Birth Date", _birthDateController),
                          _buildTextField("Mobile Number", _mobileNumberController),
                          _buildTextField("Email", _emailController),
                          _buildTextField("Username", _usernameController),
                          _buildPasswordField(),
                          if (_errorMessage != null)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red, fontSize: 14),
                              ),
                            ),

                          const SizedBox(height: 04),
                          ElevatedButton(
                            onPressed: _signup,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Already have an account? "),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, 'login');
                                },
                                child: Text(
                                  'Login',
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

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: GestureDetector(
        onTap: () => _selectDate(context),
        child: AbsorbPointer(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          labelText: "Password",
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
