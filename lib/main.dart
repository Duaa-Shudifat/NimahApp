import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'Customer_screen/1.Launch/launch_first_screen.dart';
import 'Customer_screen/Notification/notification_service.dart';
import 'firebase_options.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  await NotificationService().setupNotifications();

  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  await flutterLocalNotificationsPlugin.initialize(
    settings: initializationSettings,
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.notification != null) {
      flutterLocalNotificationsPlugin.show(
        id: 0,
        title: message.notification!.title,
        body: message.notification!.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'channel_id',
            'channel_name',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
      );
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static void setLocale() {
    _MyAppState? state = _MyAppState.instance;
    state?.refresh();
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static _MyAppState? instance;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    instance = this;
  }

  void refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LaunchScreen(),
    );
  }
}