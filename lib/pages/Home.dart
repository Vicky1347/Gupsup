import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gupsup/Model/ChatroomModel.dart';
import 'package:gupsup/Model/Firebase_helper.dart';
import 'package:gupsup/Model/UserModel.dart';
import 'package:gupsup/pages/Chatroom.dart';
import 'package:gupsup/pages/SearchPage.dart';
import 'package:gupsup/pages/loginpage.dart';

class Home extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const Home({super.key, required this.userModel, required this.firebaseUser});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.popUntil(context, (route) => route.isFirst);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Icon(Icons.logout)),
          )
        ],
        backgroundColor: Theme.of(context).canvasColor,
        centerTitle: true,
        title: const Text("GupSup"),
        elevation: 100,
        //shadowColor: Color.fromARGB(255, 179, 179, 179),
      ),
      body: SafeArea(
        child: Container(
          //decoration:BoxDecoration(image:DecorationImage(image:AssetImage('assets/pattern.jpg')  ,) ,

          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData == true) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;

                  //therw will so many chatrooms hence we need Listview builder
                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;

                      //got both our and user key
                      List<String> participantskeys =
                          participants.keys.toList();

                      participantskeys.remove(widget.userModel.uid);
                      //print("$participantskeys[0]");

                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelByID(
                            participantskeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              UserModel targetuser = userData.data as UserModel;

                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 4),
                                padding: const EdgeInsets.all(1),
                                child: ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatRoomPage(
                                            targetUser: targetuser,
                                            chatroom: chatRoomModel,
                                            userModel: widget.userModel,
                                            FirebaseUser: widget.firebaseUser),
                                      ),
                                    );
                                  },
                                  autofocus: true,
                                  isThreeLine: true,
                                  horizontalTitleGap: 10,
                                  title: Text(
                                    targetuser.fullname.toString(),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  subtitle: (chatRoomModel.lastMessage
                                              .toString() !=
                                          "")
                                      ? (Text(
                                          chatRoomModel.lastMessage.toString()))
                                      : Text(
                                          "Say Hii ",
                                          style: TextStyle(
                                              color: Colors.blue[300]),
                                        ),
                                  leading: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.grey,
                                    backgroundImage: NetworkImage(
                                        targetuser.profilepic.toString()),
                                  ),
                                ),
                              );
                            } else {
                              return Container();
                            }
                          } else {
                            return Container();
                          }
                        },
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(snapshot.error.toString()),
                  );
                } else {
                  return const Center(child: Text("Start Search and Chat"));
                }
              } else {
                return const CircularProgressIndicator();
              }

              return const ListTile(); //return any widget to remove builder error
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          //Uihelper.showLoadingDialog("Loading...", context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                FirebaseUser: widget.firebaseUser,
                userModel: widget.userModel,
              ),
            ),
          );
        },
        child: const Icon(Icons.search),
      ),
    );
  }
}
