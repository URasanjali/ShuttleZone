import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shuttlezone/pages/onbordpages/screen1.dart';
import 'package:device_preview/device_preview.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Error initializing Firebase: $e");
  }

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      useInheritedMediaQuery: true,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      home: const Screen1(),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:shuttlezone/pages/onbordpages/screen1.dart';

// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   } catch (e) {
//     debugPrint("Error initializing Firebase: $e");
//   }

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const Screen1(),
//     );
//   }
// }
// import 'package:flutter/foundation.dart'; // For kIsWeb
// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter_stripe/flutter_stripe.dart'; // Handles both web & mobile
// import 'package:shuttlezone/pages/onbordpages/screen1.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   try {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   } catch (e) {
//     debugPrint("Error initializing Firebase: $e");
//   }

//   // Initialize Stripe
//   Stripe.publishableKey = "pk_test_51Q7ymXRrLNtV0o2Mvz4a2uUjm6WMDsro1DAhOMt7gc7UrB5x3JCU5PBlMBIjA1O9eFdvBXyAeNR6pwlkgaIHqaQ1005oAoYyJS"; // Replace with your real key
//   await Stripe.instance.applySettings();

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const Screen1(),
//     );
//   }
// }
