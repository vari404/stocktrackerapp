import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stocktrackerapp/widgets/app_drawer.dart';
import 'package:stocktrackerapp/widgets/custom_app_bar.dart';
import 'package:stocktrackerapp/widgets/bottom_nav_bar.dart';
import 'package:stocktrackerapp/services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _syncUserInfo();
  }

  void _syncUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          setState(() {
            _nameController.text = snapshot.data()?['name'] ?? '';
            _emailController.text = snapshot.data()?['email'] ?? '';
          });
        }
      });
    }
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;

      case 1:
        Navigator.pushReplacementNamed(context, '/watchlist');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/newsfeed');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(title: 'Profile'),
        drawer: AppDrawer(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildProfileIcon(context),
              const SizedBox(height: 20),
              _buildUserInfoForm(context),
              const SizedBox(height: 20),
              _buildPasswordChangeForm(context),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavBar(
          currentIndex:
              0, // Use a default valid index or the last active index.
          onTabSelected: (index) => _onTabSelected(context, index),
        ));
  }

  /// Builds the profile icon
  Widget _buildProfileIcon(BuildContext context) {
    return Center(
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.transparent,
        child: Icon(
          Icons.account_circle,
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  /// Builds the user information form (Name & Email)
  Widget _buildUserInfoForm(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextFormField(
                controller: _nameController,
                labelText: 'Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _emailController,
                labelText: 'Email',
                icon: Icons.email,
                validator: (value) {
                  if (value == null || value.isEmpty || !value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  if (_formKey.currentState?.validate() ?? false) {
                    // Update user info (name and email)
                    await _firebaseService.updateUserInfo(
                      _nameController.text.trim(),
                      _emailController.text.trim(),
                      context,
                    );
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the password change form
  Widget _buildPasswordChangeForm(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.white.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextFormField(
              controller: _currentPasswordController,
              labelText: 'Current Password',
              icon: Icons.lock,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your current password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _newPasswordController,
              labelText: 'New Password',
              icon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a new password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (_currentPasswordController.text.isNotEmpty &&
                    _newPasswordController.text.isNotEmpty) {
                  await _firebaseService.updatePassword(
                    _currentPasswordController.text,
                    _newPasswordController.text,
                    context,
                  );
                }
              },
              child: const Text('Save Password'),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable method to build a text form field
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        icon: Icon(icon),
      ),
      obscureText: obscureText,
      validator: validator,
    );
  }
}
