import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gupsup/Model/ChatroomModel.dart';
import 'package:gupsup/Model/Firebase_helper.dart';
import 'package:gupsup/Model/UserModel.dart';
import 'package:gupsup/pages/Chatroom.dart';
import 'package:gupsup/pages/SearchPage.dart';
import 'package:gupsup/pages/keyy.dart';
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
              child: const Icon(Icons.logout),
            ),
          )
        ],
        backgroundColor: Theme.of(context).canvasColor,
        centerTitle: true,
        title: const Text("GupSup"),
        elevation: 100,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(widget.userModel.fullname ?? "User Name"),
              accountEmail: Text(widget.firebaseUser.email ?? "Email"),
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  widget.userModel.profilepic ??
                      "https://www.example.com/default_profile_pic.jpg",
                ),
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Keyylock(),
                  ),
                );
              },
              child: ListTile(
                leading: Icon(Icons.key),
                title: Text("Key"),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Keyylock(),
                    ),
                  );
                  //Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              leading: Icon(Icons.account_circle),
              title: Text("Profile"),
              onTap: () {
                // Add navigation to profile page here
                // Navigator.push(
                //   context,
                //   // MaterialPageRoute(
                //   //   builder: (context) =>
                //   //       ProfilePage(), // Replace with your ProfilePage
                //   // ),
                // );
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {
                // Add navigation to settings page here
                // Navigator.push(
                //   context
                //   // MaterialPageRoute(
                //   //   builder: (context) =>
                //   //       SettingsPage(), // Replace with your SettingsPage
                //   // ),
                // );
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text("Logout"),
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
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('chatrooms')
                .where("participants.${widget.userModel.uid}", isEqualTo: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.active) {
                if (snapshot.hasData) {
                  QuerySnapshot chatRoomSnapshot =
                      snapshot.data as QuerySnapshot;

                  return ListView.builder(
                    itemCount: chatRoomSnapshot.docs.length,
                    itemBuilder: (context, index) {
                      ChatRoomModel chatRoomModel = ChatRoomModel.fromMap(
                          chatRoomSnapshot.docs[index].data()
                              as Map<String, dynamic>);

                      Map<String, dynamic> participants =
                          chatRoomModel.participants!;

                      List<String> participantsKeys =
                          participants.keys.toList();

                      participantsKeys.remove(widget.userModel.uid);

                      return FutureBuilder(
                        future: FirebaseHelper.getUserModelByID(
                            participantsKeys[0]),
                        builder: (context, userData) {
                          if (userData.connectionState ==
                              ConnectionState.done) {
                            if (userData.data != null) {
                              UserModel targetUser = userData.data as UserModel;

                              return GestureDetector(
                                onTap: () {
                                  print("Tapped on ${targetUser.fullname}");
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatRoomPage(
                                        targetUser: targetUser,
                                        chatroom: chatRoomModel,
                                        userModel: widget.userModel,
                                        FirebaseUser: widget.firebaseUser,
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.all(1),
                                  child: ListTile(
                                    isThreeLine: true,
                                    title: Text(
                                      targetUser.fullname.toString(),
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    subtitle:
                                        (chatRoomModel.lastMessage.toString() !=
                                                "")
                                            ? Text(chatRoomModel.lastMessage
                                                .toString())
                                            : Text(
                                                "Say Hi ",
                                                style: TextStyle(
                                                    color: Colors.blue[300]),
                                              ),
                                    leading: CircleAvatar(
                                      radius: 30,
                                      backgroundColor: Colors.grey,
                                      backgroundImage: NetworkImage(
                                          targetUser.profilepic.toString()),
                                    ),
                                  ),
                                ),
                              );
                            } else {
                              return Container(
                                child: const Center(
                                  child: Text("User not found"),
                                ),
                              );
                            }
                          } else {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
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
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
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
