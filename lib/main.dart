import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shuttlezone/pages/onbordpages/screen1.dart';

import 'firebase_options.dart'; 

//import 'package:device_preview/device_preview.dart'; // Import the package

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Error initializing Firebase: $e");
  }

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
      home: const Screen1(),
      
    );
  }
}
