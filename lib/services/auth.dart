import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class AuthService {
  FirebaseAuth auth = FirebaseAuth.instance;

UserModel? _userFromFirebaseUser(User? user){
  return user != null ? UserModel(id: user.uid) : null;
}
Stream<UserModel?> get user{
  return auth.authStateChanges().map(_userFromFirebaseUser); 
}
  Future signUpAction(String email, String password) async {
    try {
      User user = (await auth.createUserWithEmailAndPassword(
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
  Future? signOutAction() async {
    try{
      return await auth.signOut();
    }catch(e){
      print(e);
      return null;
    }
  }
}