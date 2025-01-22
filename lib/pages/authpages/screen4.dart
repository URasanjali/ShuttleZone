import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shuttlezone/pages/authpages/auth_page.dart';
import 'package:shuttlezone/pages/authpages/login.dart';

class Screen4 extends StatefulWidget {
  final VoidCallback showLogin;

  const Screen4({super.key, required this.showLogin});

  @override
  _Screen4State createState() => _Screen4State();
}

class _Screen4State extends State<Screen4> {
  bool acceptTerms = false;
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String? errorMessage;
  String selectedRole = 'User';

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

Future<void> signUp() async {
  setState(() {
    errorMessage = null;
  });

  // Input validation
  if (usernameController.text.trim().isEmpty ||
      emailController.text.trim().isEmpty ||
      passwordController.text.isEmpty ||
      confirmPasswordController.text.isEmpty) {
    setState(() {
      errorMessage = "Please fill all fields";
    });
    return;
  }

  if (passwordController.text != confirmPasswordController.text) {
    setState(() {
      errorMessage = "Passwords do not match";
    });
    return;
  }

  if (!acceptTerms) {
    setState(() {
      errorMessage = "You must accept the terms and conditions";
    });
    return;
  }

  try {
    // Step 1: Create user in Firebase Authentication
    UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Determine the Firestore collection based on the selected role
    String collectionName = selectedRole == 'User' ? 'users' : 'courtOwners';

    // Step 2: Store additional user data in Firestore
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(userCredential.user!.uid)
        .set({
      'username': usernameController.text.trim(),
      'email': emailController.text.trim(),
      'role': selectedRole,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Step 3: Show success dialog and wait for user interaction
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 50,
              ),
              const SizedBox(height: 16),
              const Text(
                'Registration Successful!',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    //Navigator.pop(context); // Close the dialog
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(
                          showScreen4: () {}, // Pass any required functions
                          showSignUp: () {}, 
                          showLogin: () {}, 
                        ),
                      ),
                    ); // Navigate to the login page
                  },
                  child: const Text('OK'),
                ),
              ),
            ],
          ),
        );
      },
    );
  } on FirebaseAuthException catch (e) {
    setState(() {
      errorMessage = e.message ?? "An error occurred with authentication.";
    });
  } catch (e) {
    setState(() {
      errorMessage = "An unexpected error occurred. Please try again.";
    });
  }
}
void navigateToAuthPage() {
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AuthPage()),
    );
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Role',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            DropdownButton<String>(
              value: selectedRole,
              items: ['User', 'Court Owner'].map((role) {
                return DropdownMenuItem<String>(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
            ),
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Checkbox(
                  value: acceptTerms,
                  onChanged: (value) {
                    setState(() {
                      acceptTerms = value ?? false;
                    });
                  },
                ),
                const Text('I accept the terms and conditions'),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: signUp,
                child: const Text('Sign Up'),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't you have an account? "),
                  GestureDetector(
                    onTap:navigateToAuthPage,// Navigate to login
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}