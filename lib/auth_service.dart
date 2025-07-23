import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // sign in with email & password
  Future<UserCredential> signInWithEmailPassword(String email, String password) async {
    try {
      print('sign in');
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user info if not exists
      _firestore.collection('Users').doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
        SetOptions(merge: true),  // 避免覆蓋已存在資料
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  // sign up with email & password
  Future<UserCredential> signUpWithEmailPassword(String email, String password) async {
    try {
      print("sign up");
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      _firestore.collection('Users').doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print("Firebase catch error");
      throw Exception(e.code);
    }
  }

  // sign out
  Future<void> signOut() async {
    print("sign out");
    return await _auth.signOut();
  }
}
