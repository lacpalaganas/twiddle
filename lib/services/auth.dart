import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;

UserModel _userFromFirebaseUser(User user) {
    return user != null ? UserModel(id: user.uid) : null;
  }

Stream<UserModel> get user {
    return auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future signUpAction(String email, String password, int credits) async {
    try {
      UserCredential user = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await FirebaseFirestore.instance.collection('users').doc(user.user.uid)
      .set({'name' : email, 'email' : email, 'credits' : credits});
      _userFromFirebaseUser(user.user);
    } on FirebaseAuthException catch (e) {
     if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future signInAction(String email, String password) async {
    try {
      User user = (await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      )) as User;
       _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
     print(e);
    } catch (e) {
      print(e);
    }
  }
  Future signOutAction() async {
    try {
      return await auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
