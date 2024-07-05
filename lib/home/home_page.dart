import 'package:chat_app_socket/group/group_page.dart';
import 'package:chat_app_socket/home/welcome_page.dart';
import 'package:flutter/material.dart';

import '../db/pref.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SharedPreferencesData prefData = SharedPreferencesData();

  TextEditingController userNameController = TextEditingController();
  TextEditingController groupNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  List<String> contactList = ['Group 1', 'Group 2', 'Group 3', 'Group 4'];
  late String userName;
  late String userId;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  getUserData() {
    //get username from pref
    Future<String?> name = prefData.getUserName('username');
    name.then((value) {
      setState(() {
        userName = value.toString();
        // print("--------------$userName-------");
      });
    });

    //get userid from pref
    Future<String?> id = prefData.getUserName('userid');
    id.then((value) {
      setState(() {
        userId = value.toString();
        // print("--------------$userId-------");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('G-Chat',
            style: TextStyle(
                fontSize: 25,
                color: Colors.deepPurpleAccent.withOpacity(0.8),
                fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () async {
            await prefData.removeUserName('username');
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => WelcomeScreen(),));
          }, icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          return addNewGroup();
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemCount: contactList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    onTap: () {

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GroupPage(
                                      name: userName,
                                      userId: userId, //uuid.v1(),
                                      room: contactList[index].toString(),
                                    )));

                    },
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey,
                      child: Text(
                        contactList[index].substring(0, 1).toString(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(contactList[index].toString()),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }


  addNewGroup() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Please enter group name"),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: groupNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Group name',
                label: Text('Enter Group Name:'),
              ),
              validator: (value) {
                if (value == null || value.length < 3) {
                  return "Enter proper group name";
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                groupNameController.clear();
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 16),
              ),
            ),
            TextButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  // name = userNameController.text;
                  setState(() {
                    contactList.add(groupNameController.text);
                  });

                  print("===============${contactList.toString()}");

                  userNameController.clear();
                  Navigator.pop(context);
                }
              },
              child: const Text(
                "Enter",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        );
      },
    );
  }
}
