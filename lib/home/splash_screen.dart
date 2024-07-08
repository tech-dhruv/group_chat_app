import 'dart:async';

import 'package:chat_app_socket/db/pref.dart';
import 'package:chat_app_socket/home/home_page.dart';
import 'package:chat_app_socket/home/welcome_page.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var userName;
  final SharedPreferencesData prefData = SharedPreferencesData();

  @override
  void initState() {
    super.initState();
     getUsername();
    Timer(
      const Duration(seconds: 3),
      () {
        userName == ""
            ? Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => WelcomeScreen(),
              ))
            : Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomePage(),
                ));
      },
    );
  }

  getUsername() {
    Future<String?> name = prefData.getUserName('username');
    name.then((value) {
      setState(() {
        userName = value;
        print("=============$userName-------");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/chatapp_logo.jpg',width: 250,height: 300,),
            const SizedBox(height: 25),
             Text(
              "Welcome to G-Chat",
              style: TextStyle(
                  fontSize: 35,
                  color: Colors.deepPurpleAccent.withOpacity(0.9),
                  fontWeight: FontWeight.w900),
            )
          ],
        ),
      ),
    );
  }
}
