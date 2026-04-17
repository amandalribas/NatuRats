import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NaturatsApp());
}

class NaturatsApp extends StatelessWidget {
  const NaturatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NatuRats",
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      )
    );
  }
}