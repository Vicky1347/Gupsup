import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:gupsup/Model/UserModel.dart';

//to fetch Usermodlel from the Firebase
class FirebaseHelper {
  //static helping to acess all function
  static Future<UserModel?> getUserModelByID(String uid) async {
    UserModel? userModel;
    DocumentSnapshot docsnap =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();

    if (docsnap.data() != null) {
      userModel = UserModel.fromMap(docsnap.data() as Map<String, dynamic>);
    }

    //docsnap.data() is null return same userModel that was already null
    return userModel;
  }

  static Future<UserModel?> searchUserByEmail(String email) async {
    UserModel? searchedUser;
    //getting a Query snapshot from firebse
    QuerySnapshot firestore = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (firestore.docs.isNotEmpty) {
      //taking first data from the snapshot as a map
      Map<String, dynamic> userMap =
          firestore.docs[0].data() as Map<String, dynamic>;

      //Changing map to userModel
      searchedUser = UserModel.fromMap(userMap);
      return searchedUser;
    }
    return null;
  }
}
