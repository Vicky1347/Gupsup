import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gupsup/Model/Uihealper.dart';
import 'package:gupsup/Model/UserModel.dart';
import 'package:gupsup/pages/completeProfile.dart';
import 'package:gupsup/pages/loginpage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController cPasswordController = TextEditingController();

  void cheakvalues() {
    String email = emailController.text.trim(); // trim-->remove space from last
    String password = passwordController.text.trim();
    String cPassword = cPasswordController.text.trim();

    //print("hello0----");

    if (email.isEmpty || password == " " || cPassword == " ") {
      //Uihelper.showAlertDialog(context, "Alert", "Please fill all fields");
      //print("Please fill all the fields");

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
    } else if (password != cPassword) {
      //print("Password not match with confirm password");
      Uihelper.showAlertDialog(
          context, "An error occurred", "Password mismatch");
    } else {
      //print("signup sucessfully");
      signup(email, password);
    }
  }

//we give email and pass tp firebase and get credentials UserCredential
  void signup(String email, String password) async {
    Uihelper.showLoadingDialog("Plese wait..", context);
    UserCredential? credential;

    try {
      credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Navigator.pop(context);
        Uihelper.showAlertDialog(context, "An error occurred", e.toString());
        //print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        Navigator.pop(context);
        Uihelper.showAlertDialog(context, "An error occurred", e.toString());
        //print('The account already exists for that email.');
        setState(() {});
      }
    } catch (e) {
      Navigator.pop(context);
      Uihelper.showAlertDialog(context, "An error occurred", e.toString());
      //print(e);
    }

    //here work of firebase auth gets over-----
    //now the usercredients we have got we will save in firestore

    if (credential != null) {
      String uid = credential.user!.uid;

      UserModel newuser = UserModel(
        uid: uid,
        email: email,
        fullname: "",
        profilepic: "",
      );

      //1.making firestoreinstance-->making collection with uniqueid(uid)-->
      //uid provided by the firebase
      //.set data means setting data--. requird map
      //we will create from our user model

      await FirebaseFirestore.instance
          .collection("users")
          .doc(uid)
          .set(newuser.toMap())
          .then(
        (value) {
          //print("-------Done sucessfully-----------");
          Navigator.popUntil(context, (route) => route.isFirst);
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CompleteProfile(
                  userModel: newuser, firebaseUser: credential!.user!),
            ),
          );
        },
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
                  // Lottie.asset('assets/Animation - 1720772789763.json',
                  //     height: 200),
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
                    height: 10,
                  ),
                  TextField(
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Confirm Password"),
                    controller: cPasswordController,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  CupertinoButton(
                    onPressed: () {
                      cheakvalues();
                    },
                    color: Theme.of(context).colorScheme.primary,
                    child: const Text("SignUp"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Already have an account?"),
                        CupertinoButton(
                          child: const Text("Login"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
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
