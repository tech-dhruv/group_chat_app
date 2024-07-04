import 'package:chat_app_socket/group/group_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  var uuid = const Uuid();
  List<String> contactList = ['Group 1', 'Group 2', 'Group 3', 'Group 4'];
  String name ="";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Chat App'),
        centerTitle: true,
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
                      if (name.isNotEmpty) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    GroupPage(name: name, userId: uuid.v1(), room: contactList[index].toString(),)));
                      } else {
                        print("======Please Set Username======");
                        const snackdemo = SnackBar(
                          content: Text('Please Set Username'),
                          backgroundColor: Colors.redAccent,
                          elevation: 10,
                          behavior: SnackBarBehavior.floating,
                          margin: EdgeInsets.all(5),
                        );
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(snackdemo);
                      }
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
            TextButton(
              onPressed: () => saveName(),
              child: const Text(
                'Set Username',
                style: TextStyle(color: Colors.teal, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  saveName() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Please enter your name"),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            validator: (value) {
              if (value == null || value.length < 3) {
                return "User must have proper name";
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.clear();
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
                name = nameController.text;
                nameController.clear();
                Navigator.pop(context);
                // Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //         builder: (context) =>
                //             GroupPage(name: name, userId: uuid.v1())));
              }
            },
            child: const Text(
              "Enter",
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }
}
