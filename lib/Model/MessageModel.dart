class MessageModel {
  String? messageid;
  String? sender; //who send the message
  String? text; //what the message
  String? seen; //message seen by reciver or not
  DateTime? createdon; //when the message was created

  //constructor
  MessageModel(
      {this.sender, this.text, this.seen, this.createdon, this.messageid});

  MessageModel.fromMap(Map<String, dynamic> map) {
    messageid = map["messageid"];
    sender = map["sender"];
    text = map["text"];
    seen = map["seen"];
    createdon = map["createdon"].toDate(); //otherwise will get time stamp error
  }

  Map<String, dynamic> toMap() {
    return {
      "messageid": messageid,
      "sender": sender,
      "text": text,
      "seen": seen,
      "createdon": createdon,
    };
  }
}
