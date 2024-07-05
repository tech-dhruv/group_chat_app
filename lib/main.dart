import 'package:chat_app_socket/db/pref.dart';
import 'package:chat_app_socket/home/splash_screen.dart';
import 'package:chat_app_socket/home/welcome_page.dart';
import 'package:chat_app_socket/web_socket.dart';
import 'package:flutter/material.dart';

import 'home/home_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:  SplashScreen(),
    );
  }
}
