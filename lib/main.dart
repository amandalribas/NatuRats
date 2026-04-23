import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:naturats/controller/start_controller.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider<UserRepository>(create: (context) => UserRepository()),
  ], child: const NaturatsApp()));
}

class NaturatsApp extends StatelessWidget {
  const NaturatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NatuRats",
      home: const StartController(),
      theme: ThemeData(
        colorScheme: .fromSeed(seedColor: AppColors.bgVerde),
      )
    );
  }
}