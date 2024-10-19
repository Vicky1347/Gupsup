import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gupsup/Model/Firebase_helper.dart';
import 'package:gupsup/Model/UserModel.dart';
import 'package:gupsup/pages/Home.dart';
import 'package:gupsup/pages/signuppage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:uuid/uuid.dart';
import 'firebase_options.dart';

var uuid = const Uuid(); // Can be used in the whole app

String key = "1q2w3e4r5t";

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
      runApp(MyAppBiometricAuth(
        firebaseUser: currentUser,
        userModel: thisUserModel,
      ));
    }
  } else {
    // Not logged in
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  // Not logged in
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const SignUpPage(),
    );
  }
}

class MyAppBiometricAuth extends StatelessWidget {
  final UserModel userModel;
  final User firebaseUser;

  const MyAppBiometricAuth(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: BiometricAuthScreen(
        firebaseUser: firebaseUser,
        userModel: userModel,
      ),
    );
  }
}

class BiometricAuthScreen extends StatefulWidget {
  final UserModel userModel;
  final User firebaseUser;

  const BiometricAuthScreen({
    Key? key,
    required this.userModel,
    required this.firebaseUser,
  }) : super(key: key);

  @override
  _BiometricAuthScreenState createState() => _BiometricAuthScreenState();
}

class _BiometricAuthScreenState extends State<BiometricAuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();

  Future<void> authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to continue',
        options: const AuthenticationOptions(
          //biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        // Authentication successful, navigate to the Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(
              firebaseUser: widget.firebaseUser,
              userModel: widget.userModel,
            ),
          ),
        );
      } else {
        // Authentication failed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication failed')),
        );
      }
    } catch (e) {
      // Handle exception
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    authenticate(); // Trigger authentication when the screen is opened
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Authentication'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: authenticate,
          child: const Text('Authenticate'),
        ),
      ),
    );
  }
}
