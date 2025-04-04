import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gupsup/Model/ChatroomModel.dart';
import 'package:gupsup/Model/MessageModel.dart';
import 'package:gupsup/Model/UserModel.dart';
import 'package:gupsup/Model/myencrpy.dart';
import 'package:gupsup/main.dart';

class ChatRoomPage extends StatefulWidget {
  final UserModel targetUser;
  final ChatRoomModel chatroom;
  final UserModel userModel;
  final User FirebaseUser;

  const ChatRoomPage({
    super.key,
    required this.targetUser,
    required this.chatroom,
    required this.userModel,
    required this.FirebaseUser,
  });

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  TextEditingController messagecontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Call the function to delete old messages when the chat room is initialized
    deleteOldMessages();
  }

  // Function to delete messages older than 24 hours
  void deleteOldMessages() async {
    // Get the current time
    DateTime now = DateTime.now();

    // Reference to the messages collection
    var messagesRef = FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatroom.chatroomid)
        .collection('messages');

    // Query to find messages older than 24 hours
    var oldMessagesQuery = await messagesRef
        .where('createdon', isLessThan: now.subtract(Duration(seconds: 50)))
        .get();

    // Iterate through the old messages and delete them
    for (var doc in oldMessagesQuery.docs) {
      await messagesRef.doc(doc.id).delete();
    }

    print("Old messages deleted successfully");
  }

  void sendmessage() async {
    String msg = messagecontroller.text.trim();
    messagecontroller.clear();

    // Encrypt the message and convert it to String
    var encryptedMsg = MyEncryptionDecryption.encrptxor(msg);

    // Send message
    MessageModel newMessage = MessageModel(
      messageid: uuid.v1(),
      sender: widget.targetUser.uid,
      createdon: DateTime.now(),
      text: encryptedMsg,
      seen: 'false',
    );

    // Firestore will save locally and sync when online
    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatroom.chatroomid)
        .collection('messages')
        .doc(newMessage.messageid)
        .set(newMessage.toMap());

    // Setting the last message
    widget.chatroom.lastMessage = msg;

    FirebaseFirestore.instance
        .collection('chatrooms')
        .doc(widget.chatroom.chatroomid)
        .set(widget.chatroom.toMap());

    print("Message sent");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.grey[200],
              backgroundImage: NetworkImage(widget.targetUser.profilepic!),
            ),
            const SizedBox(width: 10),
            Text(widget.targetUser.fullname.toString()),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              // This is where the chat will go
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/image.png'),
                      fit: BoxFit.cover,
                      opacity: 0.2,
                    ),
                    gradient: LinearGradient(
                      colors: [
                        Color.fromARGB(255, 146, 226, 149),
                        Color.fromARGB(255, 172, 170, 170),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('chatrooms')
                        .doc(widget.chatroom.chatroomid)
                        .collection('messages')
                        .orderBy('createdon', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData) {
                          QuerySnapshot datasnapshot =
                              snapshot.data as QuerySnapshot;

                          return ListView.builder(
                            reverse: true,
                            itemCount: datasnapshot.docs.length,
                            itemBuilder: (context, index) {
                              MessageModel currentMessage =
                                  MessageModel.fromMap(datasnapshot.docs[index]
                                      .data() as Map<String, dynamic>);

                              return Row(
                                mainAxisAlignment: (currentMessage.sender ==
                                        widget.userModel.uid)
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.end,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: (currentMessage.sender !=
                                              widget.userModel.uid)
                                          ? Colors.grey[300]
                                          : Colors.green[100],
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      MyEncryptionDecryption.dencrptxor(
                                        currentMessage
                                            .text!, // Ensure this is base64
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (snapshot.hasError) {
                          return const Center(
                            child: Text(
                                "An error occurred. Check your internet connection."),
                          );
                        } else {
                          // chat empty
                          return const Center(
                              child: Text("Say hi to your new friend"));
                        }
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ),

              Container(
                color: Colors.grey[300],
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: TextField(
                        controller: messagecontroller,
                        maxLines:
                            null, // Infinite lines help to get enter functionality
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter message",
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        sendmessage();
                      },
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
