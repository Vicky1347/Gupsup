import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gupsup/Model/ChatroomModel.dart';
import 'package:gupsup/Model/Firebase_helper.dart';
import 'package:gupsup/Model/UserModel.dart';
import 'package:gupsup/main.dart';
import 'package:gupsup/pages/Chatroom.dart';

class SearchPage extends StatefulWidget {
  final UserModel userModel;
  final User FirebaseUser;

  const SearchPage(
      {super.key, required this.FirebaseUser, required this.userModel});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();

  String? fullname = "";
  UserModel? searcedModel;
  void findUser() async {
    searcedModel =
        await FirebaseHelper.searchUserByEmail(searchController.text);
    print("-----------------------------------------");
    //inal UserModel? SearchModel;
    fullname = searcedModel!.fullname;
    // SearchModel = await FirebaseHelper.searchUserByEmail(searchController.text);
    // fullname = SearchModel!.fullname;
    setState(() {});
  }

  Future<ChatRoomModel?> getchatroomModel(UserModel targetUser) async {
    ChatRoomModel? chatRoom;

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('chatrooms')
        .where('participants.${widget.userModel.uid}', isEqualTo: true)
        .where('participants.${targetUser.uid}', isEqualTo: true)
        .get();

    if (snapshot.docs.isNotEmpty) {
      //fetch existing chatroom
      print("Chatroom already created");

      var docdata = snapshot.docs[0].data();

      ChatRoomModel existingChatroom =
          ChatRoomModel.fromMap(docdata as Map<String, dynamic>);

      chatRoom = existingChatroom;
    } else {
      //create new one
      // print("Chatroom not created");
      ChatRoomModel newchatroom = ChatRoomModel(
        chatroomid: uuid.v1(),
        lastMessage: "",
        participants: {
          widget.userModel.uid.toString(): true,
          targetUser.uid.toString(): true,
        },
      );
      await FirebaseFirestore.instance
          .collection("chatrooms")
          .doc(newchatroom.chatroomid)
          .set(newchatroom.toMap());
      print("new chatroom created");

      chatRoom = newchatroom;
    }
    return chatRoom;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
        elevation: 10,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Email Adress"),
                controller: searchController,
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  setState(() {});
                  // findUser();
                },
                color: Theme.of(context).colorScheme.primary,
                child: const Text("Search"),
              ),
              const SizedBox(
                height: 20,
              ),

              //listtile

              // Material(
              //   elevation: 5,
              //   child: GestureDetector(
              //     child: ListTile(
              //       leading: Icon(Icons.person),
              //       title: Text(""),
              //     ),
              //   ),
              // ),

              StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .where('email', isEqualTo: searchController.text)
                      .where('email', isNotEqualTo: widget.userModel.email)
                      .snapshots(),
                  builder: ((context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.active) {
                      if (snapshot.hasData) {
                        QuerySnapshot dataSnapshot =
                            snapshot.data as QuerySnapshot;

                        if (dataSnapshot.docs.isNotEmpty) {
                          Map<String, dynamic> userMap = dataSnapshot.docs[0]
                              .data() as Map<String, dynamic>;

                          UserModel searchedUser = UserModel.fromMap(userMap);

                          return Material(
                            elevation: 5,
                            child: ListTile(
                              onTap: () async {
                                ChatRoomModel? chatRoomModel =
                                    await getchatroomModel(searchedUser);

                                if (chatRoomModel != null) {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                        FirebaseUser: widget.FirebaseUser,
                                        userModel: widget.userModel,
                                        chatroom: chatRoomModel,
                                        targetUser: searchedUser,
                                      ),
                                    ),
                                  );
                                }
                              },
                              title: Text(
                                searchedUser.fullname!,
                              ),
                              subtitle: Text(searchedUser.email!),
                              leading: CircleAvatar(
                                backgroundImage:
                                    NetworkImage(searchedUser.profilepic!),
                              ),
                              trailing: const Icon(Icons.keyboard_arrow_right),
                            ),
                          );
                        } else {
                          return const Text("No results found");
                        }
                      } else if (snapshot.hasError) {
                        return const Text("An error occurred");
                      }
                    } else {
                      return const CircularProgressIndicator();
                    }
                    return const ListTile();
                  })),

              Text(fullname!),
            ],
          ),
        ),
      ),
    );
  }
}
