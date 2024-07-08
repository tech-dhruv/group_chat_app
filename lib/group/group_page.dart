import 'package:chat_app_socket/foundation/msg_widget/other_msg_widget.dart';
import 'package:chat_app_socket/foundation/msg_widget/own_msg_widget.dart';
import 'package:chat_app_socket/group/msg_model.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../db/db_handler.dart';

class GroupPage extends StatefulWidget {
  final String name;
  final String userId;
  final String room;

  const GroupPage(
      {super.key,
      required this.name,
      required this.userId,
      required this.room});

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  DBHelper? dbHelper;
  IO.Socket? socket;
  List<MsgModel> listMsg = [];
  final TextEditingController _msgController = TextEditingController();
  bool _emojiShowing = false;
  final ScrollController _scrollController = ScrollController();
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    dbHelper = DBHelper();
    print("int call ${widget.room}");
    connect(); //for socket connection
    loadChatData(); //for load chat & data from sqlite
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          _emojiShowing = false;
        });
      }
    });
  }

  loadChatData() async {
    List<MsgModel> messages = await dbHelper!.getChatList(tblName: widget.room);
    setState(() {
      listMsg = messages;
    });
    _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + listMsg.length * 1000,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut);
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
      print("===============Received message:$msg");
      if (msg["userId"] != widget.userId) {
        setState(() {
          listMsg.add(
            MsgModel(
                msg: msg["msg"], type: msg["type"], sender: msg["senderName"]),
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
      dbHelper!.deleteTableContent(tblName: widget.room).then((value) {
        print("----------------Clean Successfully-----------------");
      }).onError((error, stackTrace) {
        print("--------------Error in Clean store chat------------------");
      });
      // clean
      // null

      print('Disconnected from socket server====');
      dbHelper!
          .insertChat(msgModel: listMsg, tblName: widget.room)
          .then((value) {
        print("======Insert successfully======");
      });
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
    socket!.disconnect();
    socket!.clearListeners();
    _msgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (_emojiShowing) {
          setState(() {
            _emojiShowing = false;
          });
        } else {
          Navigator.pop(context);
        }
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.room),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.deepPurpleAccent.withOpacity(0.2),
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: listMsg.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    if (listMsg[index].type == "ownMsg") {
                      return OwnMsgWidget(
                          sender: listMsg[index].sender,
                          msg: listMsg[index].msg);
                    } else {
                      return OtherMsgWidget(
                          sender: listMsg[index].sender,
                          msg: listMsg[index].msg);
                    }
                  },
                ),
              ),
            ),
            Column(
              children: [
                Container(
                  color: Colors.deepPurpleAccent.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15.0, vertical: 10),
                    child: Row(
                      // mainAxisSize: MainAxisSize.min,
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: TextFormField(
                            focusNode: focusNode,
                            controller: _msgController,
                            decoration: InputDecoration(
                              prefixIconColor:
                                  Colors.deepPurpleAccent.withOpacity(0.8),
                              suffixIconColor:
                                  Colors.deepPurpleAccent.withOpacity(0.8),
                              fillColor: Colors.white.withOpacity(0.6),
                              filled: true,
                              enabledBorder: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 2,
                                      color: Colors.deepPurpleAccent)),
                              hintText: "Type here...",
                              border: const OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                  borderSide: BorderSide(
                                      width: 2, color: Colors.white)),
                              contentPadding: const EdgeInsets.all(8),
                              prefixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      focusNode.unfocus();
                                      focusNode.canRequestFocus = false;
                                      _emojiShowing = !_emojiShowing;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.emoji_emotions,
                                    // color: Colors.deepPurpleAccent,
                                  )),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  _scrollController.animateTo(
                                      _scrollController
                                              .position.maxScrollExtent +
                                          70,
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOut);
                                  String msg = _msgController.text;
                                  if (msg.isNotEmpty) {
                                    sendMsg(msg, widget.name);
                                    _msgController.clear();
                                  }
                                },
                                icon: const Icon(Icons.send),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                emojiSelect()
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget emojiSelect() {
    return Offstage(
      offstage: !_emojiShowing,
      child: EmojiPicker(
        textEditingController: _msgController,
        scrollController: _scrollController,
        config: Config(
          height: 256,
          checkPlatformCompatibility: true,
          emojiViewConfig: EmojiViewConfig(
            emojiSizeMax: 28 *
                (foundation.defaultTargetPlatform == TargetPlatform.iOS
                    ? 1.2
                    : 1.0),
          ),
          swapCategoryAndBottomBar: false,
          skinToneConfig: const SkinToneConfig(),
          categoryViewConfig: const CategoryViewConfig(),
          bottomActionBarConfig: const BottomActionBarConfig(),
          searchViewConfig: const SearchViewConfig(),
        ),
      ),
    );
  }
}
