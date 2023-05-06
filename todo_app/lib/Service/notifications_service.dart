import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:todo_app/Custom/Notification_Page.dart';
import 'package:flutter/services.dart' show rootBundle;

class NotificationsService {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  initializeNotification() async {
    _configureLocalTimeZone();
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestSoundPermission: false,
            requestBadgePermission: false,
            requestAlertPermission: false,
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);

    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('appicon');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      iOS: initializationSettingsIOS,
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  displayNotification({required String title, required String body}) async {
    print("doing test");
    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'channel_id2',
      'your channel name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();
    var platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'It could be anything you pass',
    );
  }

  scheduledNotification(int hour, int minutes, var task) async {
    print("Test ScheduleNotification");
    var title = task['title'];
    var description = task['description'];
    final userID = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .where('userID', isEqualTo: userID);

    await userRef.get().then((querySnapshot) async {
      if (querySnapshot.docs.isNotEmpty) {
        var sound = querySnapshot.docs[0].get('soundNotification');
        if (sound != null) {
          var index = sound.substring(6);
          var channel = sound.startsWith('default_')
              ? 'default_sound'
              : 'sound_${sound.substring(6)}';
          final androidDetails = AndroidNotificationDetails(
            'channel_id:$channel',
            'your channel name',
            sound: RawResourceAndroidNotificationSound("$channel"),
          );

          await flutterLocalNotificationsPlugin.zonedSchedule(
            0,
            "Start Title: $title",
            "Description: $description",
            _convertTime(hour, minutes),
            NotificationDetails(android: androidDetails),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: "${title}|${description}|",
          );
        } else {
          // set default sound
          var sound = 'default_sound';
          var index = sound.substring(6);

          final androidDetails = AndroidNotificationDetails(
            'channel_id:$index',
            'your channel name',
            sound: RawResourceAndroidNotificationSound("$sound"),
          );

          await flutterLocalNotificationsPlugin.zonedSchedule(
            0,
            "Start Title: $title",
            "Description: $description",
            _convertTime(hour, minutes),
            NotificationDetails(android: androidDetails),
            androidAllowWhileIdle: true,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
            payload: "${title}|${description}|",
          );
        }
      }
    });
  }

  Future<void> _configureLocalTimeZone() async {
    tz.initializeTimeZones();
    final String timeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZone));
  }

  tz.TZDateTime _convertTime(int hour, int minutes) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduleDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minutes);

    if (scheduleDate.isBefore(now)) {
      scheduleDate = scheduleDate.add(const Duration(days: 1));
    }
    return scheduleDate;
  }

  Future selectNotification(String? payload) async {
    if (payload != null) {
      print('notification payload: $payload');
    } else {
      print("Notification Done");
    }
    if (Get.context != null) {
      Navigator.push(
        Get.context!,
        MaterialPageRoute(builder: (context) => NotifiedPage(label: payload)),
      );
    } else {
      print("Error");
      // Get.to( () => NotifiedPage(label: payload));
    }
  }

  void requestIOSPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  Future onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    Get.dialog(Text("Welcome to Flutter"));
  }
}
