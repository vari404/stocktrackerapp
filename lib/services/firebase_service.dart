import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Update User Info (Name & Email)
  Future<void> updateUserInfo(
      String name, String email, BuildContext context) async {
    User? user = _auth.currentUser;
    try {
      await user?.updateDisplayName(name);
      await user?.updateEmail(email);
      await user?.reload();
      user = _auth.currentUser;
      // Use the passed context for ScaffoldMessenger
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User info updated: ${user?.email}')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user info: $e')),
      );
    }
  }

  // Update Password
  Future<void> updatePassword(
      String currentPassword, String newPassword, BuildContext context) async {
    User? user = _auth.currentUser;
    try {
      final credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating password: $e')),
      );
    }
  }
}
