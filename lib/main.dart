import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:prescripcare/splashScreen/splashScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'featuressDetails/medicineReminder.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
Future<void> createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'your_channel_id', // id
    'your_channel_name', // name
    description: 'your_channel_description', // description
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: "AIzaSyCXw4BhmX5NgwMsLdvJnv_-AGu9SHV6jHo",
          appId: "1:164982990470:android:4d753b0e663d92b93e5307",
          messagingSenderId: "164982990470",
          projectId: "ecommerceapp-7cd08"));

  // Initialize notification service
  //await AndroidAlarmManager.initialize();
  await createNotificationChannel();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('drawable/logo');


  final InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        print('notification payload: ${response.payload}');
      }
      // Navigate to MedicineReminder page
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => MedicineReminder()),
      );
    },
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  runApp(
      const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: (_, child) {
        return MaterialApp(
          title: 'Flutter Demo',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          navigatorKey: navigatorKey,
          home: const SplashScreen(), // This will be your splash screen widget
        );
      },
    );
  }
}

