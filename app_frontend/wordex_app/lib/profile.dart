// ignore_for_file: unused_field, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Profile extends StatefulWidget {
  final Map<String, String> userDetails;

  const Profile({super.key, required this.userDetails});

  @override
  ProfileState createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  bool _isEditable = false;
  bool _showPasswordForm = false;
  bool _isLoading = true;

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _birthdateController;
  late TextEditingController _mobileController;
  late TextEditingController _currentPasswordController;
  late TextEditingController _newPasswordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _usernameController;

  String? _existingPassword;
  String? _errorMessage;
  String? _successMessage;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _usernameController = TextEditingController(text: widget.userDetails['userName'] ?? '');
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _birthdateController = TextEditingController();
    _mobileController = TextEditingController();
    _currentPasswordController = TextEditingController();
    _newPasswordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    if (_usernameController.text.isNotEmpty) {
      _fetchUserDetails();
    }
  }

  Future<void> _fetchUserDetails() async {
    final String userName = _usernameController.text.trim();
    if (userName.isEmpty) return;

    try {
      final response = await http.get(Uri.parse('http://172.20.10.2:8080/users/username/$userName'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userId = data['id'];
          _firstNameController.text = data['firstName'] ?? '';
          _lastNameController.text = data['lastName'] ?? '';
          _emailController.text = data['email'] ?? '';
          _birthdateController.text = data['birthDate'] ?? '';
          _mobileController.text = data['mobileNumber'] ?? '';
          _existingPassword = data['password'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to fetch user details.';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error fetching user details: $error';
        _isLoading = false;
      });
    }
  }

void _showLogoutDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Confirm Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("No"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog first
              _logout(); // Call the logout function
            },
            child: Text("Yes"),
          ),
        ],
      );
    },
  );
}


void _logout() {
  Navigator.of(context).pushReplacementNamed('login');
}


  Future<void> _updateProfile() async {

    final updatedUser = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'birthDate': _birthdateController.text.trim(),
      'mobileNumber': _mobileController.text.trim(),
      'userName': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _existingPassword ?? '',
    };

    try {
      final response = await http.put(
        Uri.parse('http://172.20.10.2:8080/users/$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedUser),
      );

      if (response.statusCode == 200) {
        setState(() {
          _successMessage = 'Profile updated successfully!';
          _errorMessage = null;
          _isEditable = false;
        });
      } else {
        setState(() => _errorMessage = 'Failed to update profile.');
      }
    } catch (error) {
      setState(() => _errorMessage = 'Error updating profile: $error');
    }
  }


   Future<void> _updatePassword() async {
    if (_currentPasswordController.text.isEmpty || _newPasswordController.text.isEmpty || _confirmPasswordController.text.isEmpty) {
      setState(() => _errorMessage = 'Please fill in all password fields.');
      return;
    }

    if (_currentPasswordController.text != _existingPassword) {
      setState(() => _errorMessage = 'Current password is incorrect!');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      setState(() => _errorMessage = 'New passwords do not match!');
      return;
    }

        final updatedUser = {
      'firstName': _firstNameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'birthDate': _birthdateController.text.trim(),
      'mobileNumber': _mobileController.text.trim(),
      'userName': _usernameController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _newPasswordController.text.trim(),
    };

    try {
      final response = await http.put(
        Uri.parse('http://172.20.10.2:8080/users/$_userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(updatedUser),
      );

      if (response.statusCode == 200) {
        setState(() {
          _existingPassword = _newPasswordController.text;
          _successMessage = 'Password updated successfully!';
          _showPasswordForm = false;
        });
      } else {
        setState(() => _errorMessage = 'Failed to update password.');
      }
    } catch (error) {
      setState(() => _errorMessage = 'Error updating password: $error');
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _mobileController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Widget _buildUserDetail(String label, TextEditingController controller, IconData icon) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: _isEditable
          ? TextField(controller: controller, decoration: InputDecoration(hintText: label))
          : Text(controller.text),
    );
  }

  Widget _buildPasswordForm() {
    return Column(
      children: [
        TextField(controller: _currentPasswordController, decoration: InputDecoration(labelText: 'Current Password')),
        TextField(controller: _newPasswordController, decoration: InputDecoration(labelText: 'New Password')),
        TextField(controller: _confirmPasswordController, decoration: InputDecoration(labelText: 'Confirm Password')),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(onPressed: () => setState(() => _showPasswordForm = false), child: Text('Cancel')),
            ElevatedButton(onPressed: _updatePassword, child: Text('Submit')),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        children: [
          Center(
            child: Text(
              'My Profile',
              style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
            ),
          ),
          const SizedBox(height: 20),
          _buildUserDetail('First Name', _firstNameController, Icons.person),
          _buildUserDetail('Last Name', _lastNameController, Icons.person_add),
          _buildUserDetail('Email', _emailController, Icons.email),
          _buildUserDetail('Birthdate', _birthdateController, Icons.cake),
          _buildUserDetail('Mobile', _mobileController, Icons.phone),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => setState(() => _isEditable = !_isEditable), child: Text(_isEditable ? 'Cancel' : 'Edit Profile')),
          if (_isEditable) ElevatedButton(onPressed: _updateProfile, child: Text('Save Details')),
          ElevatedButton(onPressed: () => setState(() => _showPasswordForm = true), child: Text('Change Password')),
          ElevatedButton(onPressed: _showLogoutDialog,style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 228, 64, 53),foregroundColor: Colors.black,),child: Text('Logout'),
),
          if (_showPasswordForm) _buildPasswordForm(),
        ],
      ),
    );
  }
}

