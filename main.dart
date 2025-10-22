
 // lib/main.dart
 // <-- أضف هذا السطر 
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart'; // Required for platform-specific Firebase options
import 'screens/chat_screen.dart';
import 'screens/auth/account_choice_screen.dart';
import 'screens/auth/provider_dashboard.dart';
import 'screens/auth/user_home_screen.dart';
import 'screens/auth/auth_gate.dart';

import 'admin/admin_dashboard_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Firebase once; guard against duplicate initialization on hot-reload or multiple isolates.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    // Ignore duplicate-app errors safely.
    if (e.code != 'duplicate-app') rethrow;
  }
  // Handle when app opened from terminated state via notification
  final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
  if (initialMessage != null) {
    _handleMessage(initialMessage);
  }
  // Handle notification taps while app in background
  FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  runApp(const SouqApp());
}

void _handleMessage(RemoteMessage message) {
  final chatId = message.data['chatId'];
  final receiverId = message.data['receiverId'];
  if (chatId != null && receiverId != null) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          receiverId: receiverId,
          // category is optional on the screen; kept for parity if needed later
        ),
      ),
    );
  }
}

class SouqApp extends StatelessWidget {
  const SouqApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'السوق الشامل',
      theme: ThemeData(primarySwatch: Colors.teal, fontFamily: 'Tajawal'),
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: const AuthGate(),
      
      routes: {
        '/account_choice': (_) => const AccountChoiceScreen(),
        '/provider_dashboard': (_) => const ProviderDashboard(),
        '/user_home': (_) => const UserHomeScreen(),
        '/admin': (_) => const AdminDashboardScreen(),
      },
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child!,
      ),
    );
  }
}