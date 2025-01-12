import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../onbordpages/screen3.dart';

class Login extends StatefulWidget {
final VoidCallback showScreen4; // Callback to toggle to SignUp screen

  const Login({super.key, required this.showScreen4, required Null Function() showSignUp, required void Function() showLogin});
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login(String email, String password, BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    try {
      // Sign in with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Get the user ID (UID)
      String uid = userCredential.user!.uid;

      // Access Firestore and check for user details
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // User details exist in Firestore, navigate to Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Screen3()),
        );
      } else {
        // User not found in Firestore
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User details not found in Firestore.")),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Authentication errors
      String errorMessage = e.message ?? "An unknown error occurred.";
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: $errorMessage")),
      );
    } catch (e) {
      // Handle Firestore or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.toString()}")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 29.5, fontWeight: FontWeight.bold, fontFamily: 'Arial'),
              ),
              const SizedBox(height: 40),
              const Text("Email", style: TextStyle(fontSize: 18.0, fontFamily: 'Arial')),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Password", style: TextStyle(fontSize: 18.0, fontFamily: 'Arial')),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          String email = emailController.text.trim();
                          String password = passwordController.text.trim();
                          _login(email, password, context);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF09663F),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login',
                          style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'Arial'),
                        ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 20.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Forgot Password?",
                    style: TextStyle(fontSize: 15.0, fontFamily: 'Arial', color: Color(0xFF09663F)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  "or login with",
                  style: TextStyle(fontSize: 15.0, fontFamily: 'Arial'),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle Google login here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Image.asset(
                    'assets/google-logo.png',
                    width: 24,
                    height: 24,
                  ),
                  label: const Text('Login with Google', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Handle Facebook login here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Colors.grey.shade300),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Image.asset(
                    'assets/facebook-new.png',
                    width: 24,
                    height: 24,
                  ),
                  label: const Text('Login with Facebook', style: TextStyle(color: Colors.black)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: widget.showScreen4, // This triggers the callback to show SignUp
                    child: const Text('Sign Up', style: TextStyle(color: Colors.green)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
