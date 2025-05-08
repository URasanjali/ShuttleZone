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
  String selectedRole = 'Court Booker';

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }



// Future<void> signUp(dynamic confirmPassword) async {
//   setState(() {
//     errorMessage = null;
//   });

//   if (usernameController.text.trim().isEmpty ||
//       emailController.text.trim().isEmpty ||
//       passwordController.text.isEmpty ||
//       confirmPasswordController.text.isEmpty) {
//     setState(() {
//       errorMessage = "Please fill all fields";
//     });
//     return;
//   }

//   if (passwordController.text != confirmPassword.text) {
//     setState(() {
//       errorMessage = "Passwords do not match";
//     });
//     return;
//   }

//   if (!acceptTerms) {
//     setState(() {
//       errorMessage = "You must accept the terms and conditions";
//     });
//     return;
//   }

//   try {
//     UserCredential userCredential =
//         await FirebaseAuth.instance.createUserWithEmailAndPassword(
//       email: emailController.text.trim(),
//       password: passwordController.text.trim(),
//     );

//     String uid = userCredential.user!.uid;
//     String role = selectedRole ?? 'User'; // ✅ Ensures role is set

//     Map<String, dynamic> userData = {
//       'username': usernameController.text.trim(),
//       'email': emailController.text.trim(),
//       'role': role, // ✅ Always sets role
//       'createdAt': FieldValue.serverTimestamp(),
//     };

//     if (role == 'Court Owner') {
//       await FirebaseFirestore.instance.collection('courtOwners').doc(uid).set(userData);
//       await removeCourtOwnerFromUsers(uid); // ✅ Remove from users if mistakenly added
//     } else {
//       await FirebaseFirestore.instance.collection('users').doc(uid).set(userData);
//     }

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text("Registration Successful"),
//         content: const Text("Your account has been created."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => Login(showScreen4: () {  }, showSignUp: () {  }, showLogin: () {  },),
//                 ),
//               );
//             },
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   } on FirebaseAuthException catch (e) {
//     setState(() {
//       errorMessage = e.message ?? "An error occurred.";
//     });
//   } catch (e) {
//     setState(() {
//       errorMessage = "Unexpected error. Please try again.";
//     });
//   }
// }

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

  if (selectedRole.isEmpty) {
    setState(() {
      errorMessage = "Please select a role";
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

    // Step 2: Store additional user data in Firestore (only for selected role)
    if (selectedRole == 'Court Booker') {
      await FirebaseFirestore.instance
          .collection('Court Booker')
          .doc(userCredential.user!.uid)
          .set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } else if (selectedRole == 'Court Owner') {
      await FirebaseFirestore.instance
          .collection('Courtowners')
          .doc(userCredential.user!.uid)
          .set({
        'username': usernameController.text.trim(),
        'email': emailController.text.trim(),
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

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
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Login(
                          showScreen4: () {},
                          showSignUp: () {},
                          showLogin: () {},
                        ),
                      ),
                    );
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

// Future<void> removeCourtOwnerFromUsers(String uid) async {
//   DocumentSnapshot userDoc =
//       await FirebaseFirestore.instance.collection('users').doc(uid).get();

//   if (userDoc.exists) {
//     await FirebaseFirestore.instance.collection('users').doc(uid).delete();
//   }
// }
// void cleanUpCourtOwners() async {
//   try {
//     // Fetch all users
//     QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();

//     for (var doc in snapshot.docs) {
//       var data = doc.data() as Map<String, dynamic>;

//       // Check if 'role' is missing or null
//       if (!data.containsKey('role') || data['role'] == null) {
//         await doc.reference.delete(); // Delete the document
//         print('Deleted user: ${doc.id}');
//       }
//     }

//     print('Cleanup completed successfully!');
//   } catch (e) {
//     print('Error cleaning up: $e');
//   }
// }


void navigateToAuthPage() {
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
}

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white,
//     body: SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 20),
//             const Text(
//               'Create Account',
//               style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 32),
//             TextField(
//               controller: usernameController,
//               decoration: const InputDecoration(labelText: 'Username'),
//             ),
//             const SizedBox(height: 24),
//             TextField(
//               controller: emailController,
//               decoration: const InputDecoration(labelText: 'Email'),
//               keyboardType: TextInputType.emailAddress,
//             ),
//             const SizedBox(height: 24),
//             TextField(
//               controller: passwordController,
//               decoration: const InputDecoration(labelText: 'Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 24),
//             TextField(
//               controller: confirmPasswordController,
//               decoration: const InputDecoration(labelText: 'Confirm Password'),
//               obscureText: true,
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Select Role',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//             ),
//             DropdownButton<String>(
//               value: selectedRole,
//               items: ['Court Booker', 'Court Owner'].map((role) {
//                 return DropdownMenuItem<String>(
//                   value: role,
//                   child: Text(role),
//                 );
//               }).toList(),
//               onChanged: (value) {
//                 setState(() {
//                   selectedRole = value!;
//                 });
//               },
//             )
//             ,
//                         if (errorMessage != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0),
//                 child: Text(
//                   errorMessage!,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ),
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Checkbox(
//                   value: acceptTerms,
//                   onChanged: (value) {
//                     setState(() {
//                       acceptTerms = value ?? false;
//                     });
//                   },
//                 ),
//                 const Text('I accept the terms and conditions'),
//               ],
//             ),
//             const SizedBox(height: 24),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: signUp,
//                 child: const Text('Sign Up'),
//               ),
//             ),
//             const SizedBox(height: 16),
//             Center(
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text("Don't you have an account? "),
//                   GestureDetector(
//                     onTap:navigateToAuthPage,// Navigate to login
//                     child: const Text(
//                       'Login',
//                       style: TextStyle(
//                         color: Colors.blue,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     ),
//   );
// }


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

            // Username Field
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Email Field
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),

            // Password Field
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // Confirm Password Field
            TextField(
              controller: confirmPasswordController,
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),

            // Select Role Dropdown
            const Text(
              'Select Role',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(5),
              ),
              child: DropdownButton<String>(
                value: selectedRole,
                isExpanded: true,
                underline: const SizedBox(),
                items: ['Court Booker', 'Court Owner'].map((role) {
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

            // Accept Terms
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
                const Expanded(
                  child: Text('I accept the terms and conditions'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Sign Up Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B6831),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16,color: Color(0xFF0A6731),),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Social Login Text
            const Center(child: Text('or login with')),
            const SizedBox(height: 16),

            // Google Login
        
            // Navigate to Login
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: navigateToAuthPage,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.green,
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