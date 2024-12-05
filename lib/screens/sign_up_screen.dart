import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final passwordController = TextEditingController();
  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  IconData iconPassword = CupertinoIcons.eye_fill;
  bool obscurePassword = true;
  bool signUpRequired = false;

  bool containsUpperCase = false;
  bool containsLowerCase = false;
  bool containsNumber = false;
  bool containsSpecialChar = false;
  bool contains8Length = false;

  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        signUpRequired = true;
      });

      try {
        // Create a new user with email and password
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        // Update the user's display name
        await userCredential.user!
            .updateProfile(displayName: nameController.text.trim());

        // Add user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': emailController.text.trim(),
          'name': nameController.text.trim(),
          'createdAt': FieldValue
              .serverTimestamp(), // Optional: Store creation timestamp
        });

        // Successfully signed up
        Navigator.pushReplacementNamed(context, '/home');
      } on FirebaseAuthException catch (e) {
        // Handle sign-up error
        String message;
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'The account already exists for that email.';
        } else {
          message = 'Sign up failed, please try again.';
        }
        // Create a SnackBar with the background color from WelcomeScreen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context)
                .colorScheme
                .primary, // Use primary color from WelcomeScreen
          ),
        );
      } finally {
        setState(() {
          signUpRequired = false; // Reset loading state
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset('lib/assets/images/logo.png', height: 180),
                const SizedBox(height: 30),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        border: InputBorder.none,
                        prefixIcon: Icon(CupertinoIcons.mail_solid),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) {
                        if (val!.isEmpty) {
                          return 'Please fill in this field';
                        } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(val)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Name',
                        border: InputBorder.none,
                        prefixIcon: Icon(CupertinoIcons.person_fill),
                      ),
                      validator: (val) {
                        if (val!.isEmpty) return 'Please fill in this field';
                        if (val.length > 30) return 'Name too long';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        border: InputBorder.none,
                        prefixIcon: const Icon(CupertinoIcons.lock_fill),
                        suffixIcon: IconButton(
                          icon: Icon(iconPassword),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                              iconPassword = obscurePassword
                                  ? CupertinoIcons.eye_fill
                                  : CupertinoIcons.eye_slash_fill;
                            });
                          },
                        ),
                      ),
                      onChanged: (val) {
                        setState(() {
                          containsUpperCase = RegExp(r'[A-Z]').hasMatch(val);
                          containsLowerCase = RegExp(r'[a-z]').hasMatch(val);
                          containsNumber = RegExp(r'[0-9]').hasMatch(val);
                          containsSpecialChar =
                              RegExp(r'[!@#\$&*~]').hasMatch(val);
                          contains8Length = val.length >= 8;
                        });
                      },
                      validator: (val) {
                        if (val!.isEmpty) return 'Please fill in this field';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    PasswordCriteria(containsUpperCase, 'Uppercase'),
                    PasswordCriteria(containsLowerCase, 'Lowercase'),
                    PasswordCriteria(containsNumber, 'Number'),
                    PasswordCriteria(containsSpecialChar, 'Special Character'),
                    PasswordCriteria(contains8Length, '8+ Characters'),
                  ],
                ),
                const SizedBox(height: 20), // Adjust spacing if needed
                if (!signUpRequired)
                  ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
                      ),
                      minimumSize: const Size(150, 40),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .primary, // Match app background color
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white), // Set text color to white
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PasswordCriteria extends StatelessWidget {
  final bool isValid;
  final String label;

  const PasswordCriteria(this.isValid, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isValid
              ? CupertinoIcons.check_mark_circled_solid
              : CupertinoIcons.circle,
          color: isValid
              ? Theme.of(context).colorScheme.primary
              : Colors.grey, // Match app background color
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }
}
