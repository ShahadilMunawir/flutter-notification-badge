import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int count = 0;
  bool isSupported = false;
  bool isNotificationAllowed = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    allowNotification();
    AppBadgePlus.isSupported().then((value) {
      isSupported = value;
      setState(() {});
    });

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification:
                (int id, String? title, String? body, String? payload) {});
    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
            macOS: initializationSettingsDarwin,
            linux: initializationSettingsLinux);

    flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('App Badge Plus is supported: $isSupported\n'),
              Text('Notification permission: $isNotificationAllowed\n'),
              TextButton(
                onPressed: () {
                  updateBadgeCount();
                },
                child: const Text('Increment Badge Count'),
              ),
              TextButton(
                onPressed: () {
                  count = 0;
                  AppBadgePlus.updateBadge(0);
                },
                child: const Text('Clear Badge Count'),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            count += 1;
            AppBadgePlus.updateBadge(count);
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void allowNotification() async {
    if (await Permission.notification.isGranted) {
      isNotificationAllowed = true;
      setState(() {});
    } else {
      await Permission.notification.request().then((value) {
        if (value.isGranted) {
          isNotificationAllowed = true;
          setState(() {});
          print('Permission is granted');
        } else {
          print('Permission is not granted');
          isNotificationAllowed = false;
          setState(() {});
        }
      });
    }
  }

  void updateBadgeCount() async {
    count += 1;

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'test',
      'test',
      channelDescription: 'test',
      importance: Importance.low,
      priority: Priority.low,
      ticker: 'ticker',
      number: 1,
      playSound: false,
      enableVibration: false,
      showWhen: false,
      ongoing: false,
      autoCancel: true,
      visibility: NotificationVisibility.secret,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      '',
      '',
      notificationDetails,
      payload: 'item x',
    );

    AppBadgePlus.updateBadge(count);
  }
}
