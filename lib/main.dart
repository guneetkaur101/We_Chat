import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_notification_channel/flutter_notification_channel.dart';
import 'package:flutter_notification_channel/notification_importance.dart';
import 'package:we_chat/screens/splash_screen.dart';
import 'firebase_options.dart';

 late Size mq;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp,DeviceOrientation.portraitDown])
      .then((value){
    _initializedFirebase();
    runApp(const MyApp());
  });

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WeChat',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
appBarTheme: const AppBarTheme(
  centerTitle: true,
  elevation: 2,
iconTheme: IconThemeData(color:Colors.black),
    titleTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 19,
        fontWeight: FontWeight.normal),
  backgroundColor: Colors.white
)),
      home:SplashScreen(),
    );
  }
}

_initializedFirebase() async {
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  var result = await FlutterNotificationChannel.registerNotificationChannel(
    description: 'For Showing Message Notification',
    id: 'chats',
    importance: NotificationImportance.IMPORTANCE_HIGH,
    //name is shown to user
    name: 'Chats',

  );
  print('Notification channel RESULT:$result' );
}
