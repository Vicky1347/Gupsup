import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gupsup/Model/Uihealper.dart';
import 'package:gupsup/Model/UserModel.dart';
import 'package:gupsup/pages/Home.dart';
import 'package:gupsup/pages/signuppage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void cheakvalues() {
    String email = emailController.text.trim(); // trim-->remove space from last
    String password = passwordController.text.trim();

    //print("hello0----");

    if (email.isEmpty || password == " ") {
      print("Please fill all the fields");

      setState(() {});

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 226, 221, 221),
            title: const Text(
              'Alert',
              style: TextStyle(color: Colors.red),
            ),
            content: const Text('Kindly fill all Details'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close the dialog
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      print("wait-------");
      Login(email, password);
    }
  }

  void Login(String email, String password) async {
    Uihelper.showLoadingDialog("Logging in....", context);
    UserCredential? credential;
    try {
      credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Navigator.pop(context);
        Uihelper.showAlertDialog(context, "An error occurred", e.toString());
        //print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        Navigator.pop(context);
        Uihelper.showAlertDialog(context, "An error occurred", e.toString());
        //print('Wrong password provided for that user.');
      } else if (e.code != "") {
        Navigator.pop(context);
        Uihelper.showAlertDialog(context, "An error occurred", e.toString());
      }
    }
    if (credential != null) {
      String uid = credential.user!.uid;

      DocumentSnapshot userData =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      UserModel userModel =
          UserModel.fromMap(userData.data() as Map<String, dynamic>);

      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            firebaseUser: credential!.user!,
            userModel: userModel,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Image(
                    image: AssetImage(
                      'assets/chaticon.png',
                    ),
                    height: 200,
                  ),
                  Text(
                    "GupSup",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    //obscureText: true,
                    decoration: const InputDecoration(labelText: "Email Address"),
                    controller: emailController,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    controller: passwordController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      cheakvalues();
                    },
                    color: Theme.of(context).colorScheme.primary,
                    child: const Text(" Login"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        CupertinoButton(
                          child: const Text(" SignUp"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignUpPage(),
                              ),
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
