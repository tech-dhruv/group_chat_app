import 'package:chat_app_socket/group/group_page.dart';
import 'package:chat_app_socket/home/welcome_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../db/db_handler.dart';
import '../db/pref.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SharedPreferencesData prefData = SharedPreferencesData();
  DBHelper? dbHelper;

  // TextEditingController userNameController = TextEditingController();
  TextEditingController groupNameController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  // List<String> contactList = [];
  late Future<List<String>> contactList;
  late String userName;
  late String userId;

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
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

    //get group list from sqlite
    setState(() {
      contactList = dbHelper!.getTables();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: openDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) {
            return Center(
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: Icon(
                      Icons.person,
                      color: Colors.white.withOpacity(0.8),
                      size: 25,
                    )),
              ),
            );
          },
        ),
        title: Text('G-Chat',
            style: TextStyle(
                fontSize: 25,
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () async {
                await prefData.removeUserName('username');
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                  builder: (context) => WelcomeScreen(),
                ));
              },
              icon: const Icon(Icons.logout)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurpleAccent.withOpacity(0.9),
        onPressed: () {
          return addNewGroup();
        },
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Column(
          children: [
            FutureBuilder(
              future: contactList,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: Text("Oops!! No Group Data"),
                  );
                } else if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  var snapData = snapshot.data;
                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapData?.length,
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
                                          room: snapData[index].toString(),
                                        )));
                          },
                          leading: CircleAvatar(
                            backgroundColor:
                                Colors.deepPurpleAccent.withOpacity(0.6),
                            child: Text(
                              snapData![index].substring(0, 1).toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(snapData[index].toString()),
                        ),
                      );
                    },
                  );
                }
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
                  dbHelper!
                      .createTable(groupNameController.text.toString())
                      .then((value) {
                    print('table created');
                    getUserData();
                  }).onError((error, stackTrace) {
                    print(error.toString());
                  });
                }

                groupNameController.clear();
                Navigator.pop(context);
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

  openDrawer(){
    return Drawer(
      child: Container(
        color: Colors.deepPurpleAccent.withOpacity(0.2),
        child: Column(
          children: [

          ],
        ),
      ),
    );
  }

}
