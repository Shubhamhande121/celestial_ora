// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';

// import '../main.dart';

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();
// FirebaseMessaging messaging = FirebaseMessaging.instance;

// class PushNotificationService {
//   late AndroidNotificationChannel channel;
//   BuildContext context;
//   PushNotificationService({required this.context});
//   double rate = 5;
//   late RemoteMessage messageData;
//   TextEditingController _reviewController = TextEditingController();
//   Future initialize() async {
//     iOSPermission();
//     FirebaseMessaging.instance.requestPermission();
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('app_logo');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//     flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//     );

//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       messageData = message;
//       var data = message.notification;
//       print("entered");
//       print(message.data);
//       var title = data!.title.toString();
//       var body = data.body.toString();
//       var image = message.data['image'] ?? '';

//       var type = message.data['open_page'] ?? '';

//       var id = '';
//       id = message.data['open_id'] ?? '';

//       if (image != null && image != 'null' && image != '') {
//         generateImageNotication(title, body, image, type, id);
//       } else {
//         generateSimpleNotication(title, body, type, id);
//       }
//     });

//     messaging.getInitialMessage().then((RemoteMessage? message) async {
//       // bool back = await getPrefrenceBool(ISFROMBACK);
//       // if (message != null) {
//       //   var type = message.data['open_page'] ?? '';
//       //   var id = '';
//       //   id = message.data['open_id'] ?? '';

//       //   if (type == 'invite_points') {
//       //     Navigator.of(context)
//       //         .push(MaterialPageRoute(builder: (context) => PointHistory()));
//       //   } else if (type == 'home') {
//       //     Navigator.of(context)
//       //         .push(MaterialPageRoute(builder: (context) => HomeScreen()));
//       //   } else if (type == 'all_booking') {
//       //     Navigator.of(context)
//       //         .push(MaterialPageRoute(builder: (context) => BookingScreen()));
//       //   } else if (type == 'booking_detail') {
//       //     getBookingDetails(
//       //       bookingId: id,
//       //       isCompleteBookingReview: false,
//       //     );
//       //   } else if (type == 'booking_complete_review') {
//       //     getBookingDetails(
//       //       bookingId: id,
//       //       isCompleteBookingReview: true,
//       //     );
//       //   }
//       // }
//     });

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
//       // bool back = await getPrefrenceBool(ISFROMBACK);
//       print("entered");
//       print(message.data);
//     });
//   }

//   void iOSPermission() async {
//     await messaging.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//   }

//   void onSelectNotification(String? payload) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => MyApp()),
//     );
//   }
// }

// Future<String> _downloadAndSaveImage(String url, String fileName) async {
//   var directory = await getApplicationDocumentsDirectory();
//   var filePath = '${directory.path}/$fileName';
//   var response = await http.get(Uri.parse(url));

//   var file = File(filePath);
//   await file.writeAsBytes(response.bodyBytes);
//   return filePath;
// }

// Future<void> generateImageNotication(
//     String title, String msg, String image, String type, String id) async {
//   var largeIconPath = await _downloadAndSaveImage(image, 'largeIcon');
//   var bigPicturePath = await _downloadAndSaveImage(image, 'bigPicture');
//   var bigPictureStyleInformation = BigPictureStyleInformation(
//       FilePathAndroidBitmap(bigPicturePath),
//       hideExpandedLargeIcon: true,
//       contentTitle: title,
//       htmlFormatContentTitle: true,
//       summaryText: msg,
//       htmlFormatSummaryText: true);
//   var androidPlatformChannelSpecifics = AndroidNotificationDetails(
//       'big text channel id', 'big text channel name',
//       largeIcon: FilePathAndroidBitmap(largeIconPath),
//       styleInformation: bigPictureStyleInformation);
//   var platformChannelSpecifics =
//       NotificationDetails(android: androidPlatformChannelSpecifics);
//   await flutterLocalNotificationsPlugin
//       .show(0, title, msg, platformChannelSpecifics, payload: type + "," + id);
// }

// Future<void> generateSimpleNotication(
//     String title, String msg, String type, String id) async {
//   var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
//       'your channel id', 'your channel name',
//       importance: Importance.max, priority: Priority.high, ticker: 'ticker');

//   var platformChannelSpecifics = NotificationDetails(
//     android: androidPlatformChannelSpecifics,
//   );
//   await flutterLocalNotificationsPlugin
//       .show(0, title, msg, platformChannelSpecifics, payload: type + "," + id);
// }

// Future firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   // await Firebase.initializeApp();
// }

// Future<dynamic> myForgroundMessageHandler(RemoteMessage message) async {
//   // setPrefrenceBool(ISFROMBACK, true);
//   return Future<void>.value();
// }
