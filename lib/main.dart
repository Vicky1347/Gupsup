import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gupsup/Model/Firebase_helper.dart';
import 'package:gupsup/Model/UserModel.dart';
import 'package:gupsup/pages/Home.dart';
import 'package:gupsup/pages/signuppage.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';

var uuid = const Uuid(); //can be use in whole app

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  User? currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    UserModel? thisUserModel =
        await FirebaseHelper.getUserModelByID(currentUser.uid);
    if (thisUserModel != null) {
      runApp(MyAppLoggindIn(
        firebaseUser: currentUser,
        userModel: thisUserModel,
      ));
    }
  } else {
    //Not logged in
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  //Not logged in
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      //title: 'Flutter Demo',
      // theme: ThemeData(
      //   colorScheme:
      //       ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 77, 117, 191)),
      //   useMaterial3: true,
      // ),
      home: const SignUpPage(),
    );
  }
}

//Loggg in
class MyAppLoggindIn extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppLoggindIn(
      {super.key, required this.userModel, required this.firebaseUser});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      //title: 'Flutter Demo',
      theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(
          //     seedColor: Colors.blue,
          //     primary: Colors.blue[500], // Set primary color (darker shade)
          //     secondary: Colors.teal[300]),
          // useMaterial3: true,
          ),
      home: Home(firebaseUser: firebaseUser, userModel: userModel),
    );
  }
}
