import 'package:flutter/material.dart';
import 'package:shuttlezone/pages/authpages/login.dart';
import 'screen4.dart'; // Import your Screen4 class

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginScreen = true;

  void toggleScreens() {
    setState(() {
      showLoginScreen = !showLoginScreen;
    });
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    body: showLoginScreen
        ? Login(
            showScreen4: toggleScreens, // Correct parameter to show SignUp screen
            showLogin: () {}, showSignUp: () {  },          // Dummy callback, or implement as needed
          )
        : Screen4(showLogin: toggleScreens), // Correct callback to toggle screens
  );
}

}
