import 'package:chat_app_socket/foundation/msg_widget/other_msg_widget.dart';
import 'package:chat_app_socket/foundation/msg_widget/own_msg_widget.dart';
import 'package:chat_app_socket/group/msg_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class GroupPage extends StatefulWidget {
  final String name;
  final String userId;
  final String room;

  const GroupPage({super.key, required this.name, required this.userId, required this.room});


  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  IO.Socket? socket;
  //String room = "anonymous_group";
  List<MsgModel> listMsg = [];
  final TextEditingController _msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    print("int call ${widget.room}");
    connect();
  }

  void connect() {
    socket = IO.io("http://192.168.29.245:5251", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket!.connect();


      socket!.onConnect((_) {
        print('==============connected into frontend=============');
        socket!.emit('join_room', widget.room);
        print("====>>> ${widget.room}");
      });


      socket!.on("sendMsgServer", (msg) {
        print("===============Received message:" + msg.toString());
        if (msg["userId"] != widget.userId) {
          setState(() {
            listMsg.add(
              MsgModel(
                  msg: msg["msg"],
                  type: msg["type"],
                  sender: msg["senderName"]),
            );
          });
        }
      });

    socket!.onConnectError((data) {
      print('Connection Error====: $data');
    });

    socket!.onError((data) {
      print('Error====: $data');
    });

    socket!.onDisconnect((_) {
      print('Disconnected from socket server====');

    });
  }

  void sendMsg(String msg, String senderName) {
    MsgModel ownMsg = MsgModel(msg: msg, type: "ownMsg", sender: senderName);
    setState(() {
      listMsg.add(ownMsg);
    });
    socket!.emit('sendMsg', {
      "room": widget.room,
      "type": "ownMsg",
      "msg": msg,
      "senderName": senderName,
      "userId": widget.userId,
    });
    print("=====MSG Send===== ");
  }

  @override
  void dispose() {
   socket!.clearListeners();
    socket!.disconnect();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: listMsg.length,
              itemBuilder: (context, index) {
                if (listMsg[index].type == "ownMsg") {
                  return OwnMsgWidget(
                      sender: listMsg[index].sender, msg: listMsg[index].msg);
                } else {
                  return OtherMsgWidget(
                      sender: listMsg[index].sender, msg: listMsg[index].msg);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20),
            child: SizedBox(
              height: 55,
              child: Row(
                children: [
                  Expanded(
                      child: TextFormField(
                    controller: _msgController,
                    decoration: InputDecoration(
                        hintText: "Type here...",
                        border: const OutlineInputBorder(
                            borderSide: BorderSide(
                          width: 2,
                        )),
                        suffixIcon: IconButton(
                            onPressed: () {
                              String msg = _msgController.text;
                              if (msg.isNotEmpty) {
                                sendMsg(msg, widget.name);
                                _msgController.clear();
                              }
                            },
                            icon: const Icon(Icons.send))),
                  )),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
