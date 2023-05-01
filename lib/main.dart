import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:twiddle/models/user.dart';
import 'package:twiddle/screens/auth/sign_up.dart';
import 'package:twiddle/screens/wrapper.dart';
import 'package:twiddle/services/auth.dart';

import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey = "pk_test_51Mwp94B9byJGLNxNyVAM82mAYoi9ey5SphAWlsjR9Guaadg3dlPN5pcUCEoQss54t0ojopWcyurpjxMQQl90Y4EQ00bLBdZBLx";
 await Stripe.instance.applySettings();

  // Load our .env file that contains our Stripe Secret key
  //await dotenv.load(fileName: "assets/.env");
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp( MyApp());
}

class MyApp extends StatelessWidget{
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

    MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context){
    // return StreamProvider<UserModel>.value(
    //   value: AuthService().user,
    
    // initialData: null,
    // child: const MaterialApp(
    //   home: Wrapper(),
    // ),);

    return FutureBuilder(
      // Initialize FlutterFire:
      future: _initialization,
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          //return SomethingWentWrong();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return StreamProvider<UserModel>.value(
            value: AuthService().user,
            child: MaterialApp(home: Wrapper()),
          );
        }

        // Otherwise, show something whilst waiting for initialization to complete
        return Text("Loading");
      },
    );
  }
}
