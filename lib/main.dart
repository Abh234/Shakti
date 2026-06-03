import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'screens/welcome_screen.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken("pk.eyJ1Ijoic2FtYXkwMSIsImEiOiJjbW4xeWJpcDExMW1sMnJzZmFyeGljZTU3In0.TIsucT8Ce_c-XgfBtotOPw");
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ShaktiApp());
}

class ShaktiApp extends StatelessWidget {
  const ShaktiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shakti',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2563EB),
        useMaterial3: true,
        fontFamily: 'SF Pro Display',
      ),
      home: const WelcomeScreen(),
    );
  }
}
