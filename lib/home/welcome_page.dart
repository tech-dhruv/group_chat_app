import 'package:chat_app_socket/home/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../db/pref.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  var uuid = const Uuid();
  final TextEditingController userNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final SharedPreferencesData prefData = SharedPreferencesData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Welcome to G-Chat",
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.deepPurpleAccent,
                    fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 50),
              Form(
                key: formKey,
                child: TextFormField(
                  controller: userNameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20)),
                    hintText: 'Enter Your name',
                    label: const Text('Enter Name:'),
                  ),
                  validator: (value) {
                    if (value == null || value.length < 3) {
                      return "Enter proper name";
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      //set username
                      await prefData
                          .setUserName(userNameController.text.toString());
                      //set userid
                      await prefData.setUserId(uuid.v1());

                      //print username
                      Future<String?> name = prefData.getUserName("username");
                      name.then((value) {
                        print("=====Username=====${value.toString()}");
                      });
                      //print userid
                      Future<String?> id = prefData.getUserId("userid");
                      id.then((value) {
                        print("=====UserId=====${value.toString()}");
                      });

                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ));
                    }
                  },
                  style: ButtonStyle(
                      shape: MaterialStatePropertyAll(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                          side: const BorderSide(
                              color: Colors.deepPurpleAccent, width: 2))),
                      padding: const MaterialStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 30, vertical: 15))),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      SizedBox(width: 20),
                      Icon(Icons.arrow_circle_right_outlined)
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
