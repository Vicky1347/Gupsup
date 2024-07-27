//import 'dart:html';

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gupsup/Model/Uihealper.dart';
import 'package:gupsup/Model/UserModel.dart';
import 'package:gupsup/pages/Home.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfile extends StatefulWidget {
  final UserModel userModel; //from our class
  final User firebaseUser; //from firebase auth

  const CompleteProfile(
      {super.key, required this.userModel, required this.firebaseUser});

  @override
  State<CompleteProfile> createState() => _CompleteProfileState();
}

class _CompleteProfileState extends State<CompleteProfile> {
  File? imageFile;

  TextEditingController fullnamecontroller = TextEditingController();

  void selectImage(ImageSource source) async {
    XFile? pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      cropImage(pickedFile);
    }
  }

  void cropImage(XFile file) async {
    CroppedFile? croppedImage = await ImageCropper().cropImage(
      sourcePath: file.path,
      aspectRatio:
          const CropAspectRatio(ratioX: 1, ratioY: 1), //1:1 give squre photo
      compressQuality: 30,
    );

    if (croppedImage != null) {
      setState(() {
        imageFile = File(croppedImage.path);
      });
    }
  }

  void showPhotoOptions() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Upload Profile Picture"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("cancel"))
            ],
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  onTap: () {
                    Navigator.pop(context);
                    selectImage(ImageSource.gallery);
                  },
                  leading: const Icon(Icons.photo),
                  title: const Text("Select from Gallrey"),
                ),
                ListTile(
                  onTap: () {
                    selectImage(
                      ImageSource.camera,
                    );
                  },
                  leading: const Icon(Icons.camera),
                  title: const Text("Take a Photo"),
                )
              ],
            ),
          );
        });
  }

  void cheakvalues() {
    String fullName =
        fullnamecontroller.text.trim(); // trim-->remove space from last

    //print("hello0----");

    if (fullName == "") {
      //print("Please rnter your name");

      //setState(() {});

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 226, 221, 221),
            title: const Text(
              'Alert',
              style: TextStyle(color: Colors.red),
            ),
            content: const Text('Please rnter your name'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close the dialog
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else if (imageFile == null) {
      //>print("Plese upload profile pic");
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
            content: const Text('Please Upload Your Profile pic'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), // Close the dialog
                child: const Text('OK'),
              ),
            ],
          );
        },
      );

      // Login(email, password);
    } else {
      uploadData();
    }
  }

  void uploadData() async {
    Uihelper.showLoadingDialog("Uploading Please wait....", context);
    //profile picture is the folder
    //widget.userModel!.uid--> name of file that is uid unique name

    UploadTask uploadTask = FirebaseStorage.instance
        .ref("profilepictures")
        .child(widget.userModel.uid.toString())
        .putFile(imageFile!);

    TaskSnapshot snapshot = await uploadTask;
    String? imageurl = await snapshot.ref.getDownloadURL();

    // String imageurl = await FirebaseStorage.instance
    //     .ref("profilepictures")
    //     .child(widget.userModel.uid.toString())
    //     .getDownloadURL();

    String fullname = fullnamecontroller.text.trim();

    widget.userModel.fullname = fullname;
    widget.userModel.profilepic = imageurl;

    Uihelper.showLoadingDialog("Plese wait..", context);

    await FirebaseFirestore.instance
        .collection("users")
        .doc(widget.userModel.uid)
        .set(widget.userModel.toMap())
        .then((value) {
      print("data updated");
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            userModel: widget.userModel,
            firebaseUser: widget.firebaseUser,
          ),
        ),
      );
    });
  }

  @override

//   Future<void> getLostData() async {
//   final ImagePicker picker = ImagePicker();
//   final LostDataResponse response = await picker.retrieveLostData();
//   if (response.isEmpty) {
//     return;
//   }
//   final List<XFile>? files = response.files;
//   if (files != null) {
//     _handleLostFiles(files);
//   } else {
//     _handleError(response.exception);
//   }
// }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Complete Profile"),
        elevation: 10,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: ListView(
            children: [
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  showPhotoOptions();
                },
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      (imageFile != null) ? FileImage(imageFile!) : null,
                  child: (imageFile == null)
                      ? const Icon(
                          Icons.person,
                          size: 50,
                        )
                      : null,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                controller: fullnamecontroller,
                decoration: const InputDecoration(labelText: "Full Name"),
              ),
              const SizedBox(
                height: 20,
              ),
              CupertinoButton(
                onPressed: () {
                  cheakvalues();
                },
                color: Theme.of(context).colorScheme.primary,
                child: const Text("Submit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
