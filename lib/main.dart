import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shuttlezone/pages/onbordpages/screen1.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

  // Stripe Initialization
  Stripe.publishableKey =
      "pk_test_51Q7ymXRrLNtV0o2Mvz4a2uUjm6WMDsro1DAhOMt7gc7UrB5x3JCU5PBlMBIjA1O9eFdvBXyAeNR6pwlkgaIHqaQ1005oAoYyJS"; // Replace with your Stripe test key

  // Run the app
  runApp(DevicePreview(
    enabled: true, // Set this to false to disable preview
    builder: (context) => const MyApp(), // Wrap your app
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true, // Required for DevicePreview
      locale: DevicePreview.locale(context), // Use the DevicePreview locale
      builder: DevicePreview.appBuilder, // Wrap the app builder
      home: const Screen1(), // Navigate to screen1 directly
    );
  }
}
