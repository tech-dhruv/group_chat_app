class MsgModel {
  final int? id;
  final String type;
  final String msg;
  final String sender;

  MsgModel({
    this.id,
    required this.msg,
    required this.type,
    required this.sender,
  });

   MsgModel.fromMap(Map<String, dynamic> json)
    : id = json["id"],
      type= json["type"],
      msg= json["msg"],
      sender= json["sender"];


  // Map<String, dynamic> toMap() => {
  //   "id": id,
  //   "type": type,
  //   "msg": msg,
  //   "sender": sender,
  // };

  Map<String, Object?> toMap(){
    return {
      'id' : id,
      'type' : type,
      'msg' : msg,
      'sender' : sender
    };
  }

}

