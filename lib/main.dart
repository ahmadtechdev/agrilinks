import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';

import 'utils/colors.dart';
import 'screens/welcome_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  Platform.isAndroid
      ? await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyCARrKxA8lmTiSGzX22tmgkLjNkSF3Dq_U',
          appId: '1:982121165076:android:e25035bb4e6d05b5631201',
          messagingSenderId: '982121165076',
          projectId: 'agrilinks-4912c',
          storageBucket: "gs://agrilinks-4912c.appspot.com",))
      : await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
      ),
      home:  WelcomeScreen(),
    );
  }
}
