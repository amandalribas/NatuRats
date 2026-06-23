import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:naturats/controller/start_controller.dart';
import 'package:naturats/repository/challenges_repository.dart';
import 'package:naturats/repository/user_repository.dart';
import 'package:naturats/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<UserRepository>(
          create: (context) => UserRepository()),
      Provider<ChallengesRepository>(
          create: (context) => ChallengesRepository()),
    ],
    child: const NaturatsApp(),
  ));
}

class NaturatsApp extends StatelessWidget {
  const NaturatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: "NatuRats",
      home: const StartController(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.bgVerde),
      ),
    );
  }
}