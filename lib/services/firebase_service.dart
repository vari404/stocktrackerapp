import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stocktrackerapp/models/stock_model.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Polls for email verification status and updates Firestore once verified
  Future<void> waitForEmailVerificationAndUpdateFirestore(
      String name, String newEmail, BuildContext context) async {
    User? user = _auth.currentUser;

    if (user == null) return;

    Timer.periodic(const Duration(seconds: 3), (timer) async {
      await user?.reload(); // Refresh user data
      user = _auth.currentUser;

      if (user?.emailVerified == true) {
        timer.cancel(); // Stop polling once email is verified

        // Update Firestore `users` collection with new email
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .update({'name': name, 'email': newEmail});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('User info updated after email verification.')),
        );
      }
    });
  }

  /// Validate if the email is not already in use or belongs to the current user
  Future<bool> isEmailAvailable(String email) async {
    User? currentUser = _auth.currentUser;

    // Check Firestore `users` collection
    final firestoreQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    // If email exists but belongs to the current user, it's available
    if (firestoreQuery.docs.isNotEmpty &&
        firestoreQuery.docs.first.id != currentUser?.uid) {
      return false; // Email exists in Firestore for another user
    }

    // Check Firebase Authentication
    try {
      final signInMethods =
          await _auth.fetchSignInMethodsForEmail(email.trim());

      // If email exists in Firebase Auth but matches the current user's email, it's available
      if (signInMethods.isNotEmpty && currentUser?.email != email) {
        return false; // Email exists in Firebase Auth for another user
      }
    } catch (_) {
      // Ignore errors for non-existent emails
    }

    return true; // Email is available
  }

  /// Update User Info (Name & Email) in both Authentication and Firestore
  Future<void> updateUserInfo(
      String name, String email, BuildContext context) async {
    User? user = _auth.currentUser;

    if (user == null) return;

    try {
      // Only check availability if the email has changed
      if (user.email != email) {
        final emailAvailable = await isEmailAvailable(email);

        if (!emailAvailable) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email is already in use.')),
          );
          return;
        }

        // Send email verification before updating the email
        await user.verifyBeforeUpdateEmail(email);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification email sent.')),
        );

        // Wait for email verification and update Firestore
        await waitForEmailVerificationAndUpdateFirestore(name, email, context);
        return;
      }

      // Update Firebase Authentication
      await user.updateDisplayName(name);

      // Update Firestore `users` collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': name,
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User info updated successfully.')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating user info: ${e.message}')),
      );
    }
  }

  /// Updates the user's password after validating the current password and new password criteria
  Future<void> updatePassword(
      String currentPassword, String newPassword, BuildContext context) async {
    User? user = _auth.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is currently logged in.')),
      );
      return;
    }

    try {
      // Re-authenticate the user with their current password
      final email = user.email;
      if (email == null) throw FirebaseAuthException(code: 'email-not-found');

      final credential =
          EmailAuthProvider.credential(email: email, password: currentPassword);

      await user.reauthenticateWithCredential(credential);

      // Validate new password
      final passwordValidationError = _validatePassword(newPassword);
      if (passwordValidationError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(passwordValidationError)),
        );
        return;
      }

      // Update the password
      await user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully.')),
      );
    } on FirebaseAuthException catch (e) {
      // Map Firebase exceptions to user-friendly messages
      String errorMessage;

      switch (e.code) {
        case 'wrong-password':
          errorMessage = 'The current password entered is incorrect.';
          break;
        case 'weak-password':
          errorMessage = 'The new password is too weak. Please try again.';
          break;
        case 'requires-recent-login':
          errorMessage =
              'Your session has expired. Please log in again to update the password.';
          break;
        default:
          errorMessage = 'An unexpected error occurred: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
  }

  /// Validates the new password based on the criteria
  String? _validatePassword(String password) {
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasSpecialCharacter =
        password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    final hasMinLength = password.length >= 8;

    if (!hasUppercase) {
      return 'Password must contain at least one uppercase letter.';
    }
    if (!hasLowercase) {
      return 'Password must contain at least one lowercase letter.';
    }
    if (!hasSpecialCharacter) {
      return 'Password must contain at least one special character.';
    }
    if (!hasMinLength) {
      return 'Password must be at least 8 characters long.';
    }

    return null;
  }

  Future<void> addToWatchlist(String symbol) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(symbol);

    await docRef.set({'symbol': symbol});
  }

  Future<void> removeFromWatchlist(String symbol) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(symbol);

    await docRef.delete();
  }

  Future<bool> isSymbolInWatchlist(String symbol) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .doc(symbol);

    final doc = await docRef.get();
    return doc.exists;
  }

  // Get the currently logged-in user
  User? getUser() {
    return _auth.currentUser;
  }

  // Get the user's watchlist from Firestore
  Future<List<String>> getUserWatchlist() async {
    final user = getUser();
    if (user == null) {
      throw Exception("No user is currently logged in.");
    }

    final watchlistSnapshot = await _firestore
        .collection('users')
        .doc(user.uid)
        .collection('watchlist')
        .get();

    return watchlistSnapshot.docs
        .map((doc) => doc.data()['symbol'] as String)
        .toList();
  }

  // Firestore listener to track real-time changes in the 'stocks' collection
  Stream<List<Stock>> getStocksStream() {
    return _firestore.collection('stocks').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => Stock.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }
}
