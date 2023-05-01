import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twiddle/screens/home/search.dart';
import 'package:twiddle/services/auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';

import '../home/feed.dart';


class Home extends StatefulWidget {
  Home({Key key}) : super(key: key);

@override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void initState(){
    
    print("init");
    super.initState();
    getUserInfo();
    
  }

   Map<String, dynamic> paymentIntent;
    int credits = 0;
    String email = '';
   //var credits = "";
    final AuthService _authService = AuthService();
    int _currentIndex = 0;
    final List<Widget> _children = [
      Feed(),
      Search()
    ];
    void onTabPressed(int index){
      setState(() {
        _currentIndex = index;
      });
    }
    final usersRef = FirebaseFirestore.instance.collection("users");
     final currentUser = FirebaseAuth.instance.currentUser.uid;
     getUserInfo () async{
   final DocumentSnapshot doc =  await usersRef.doc(currentUser).get();
   // usersRef.doc(currentUser).get().then((DocumentSnapshot doc){
     // credits = doc.get('credits');
    //});
    setState(() {
       credits = doc.get('credits');
       email = doc.get('email');
    });
  
  //  if(credits == null){
  //   credits = 0;
  //  }
  //  print("credits $credits");
   
  }

  updateCredits(int newCredits) async{
      newCredits = credits + 100;
       await FirebaseFirestore.instance.collection('users').doc(currentUser)
       .update({'credits': newCredits});
  }

@override
  Widget build(BuildContext context) {

     Future<void> initPaymentSheet(context, { String email,  int amount}) async {
      try {
        // 1. create payment intent on the server
        final response = await http.post(
            Uri.parse(
                'https://us-central1-twiddle-b4eed.cloudfunctions.net/stripePaymentIntentRequest'),
            body: {
              'email': email,
              'amount': amount.toString(),
            });

        final jsonResponse = jsonDecode(response.body);
        log(jsonResponse.toString());

        //2. initialize the payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            merchantDisplayName: 'twiddle',
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
            style: ThemeMode.light,
            //testEnv: true,
            //merchantCountryCode: 'SG',
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment completed!')),
        );
  
      updateCredits(credits);
      } catch (e) {
        if (e is StripeException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error from Stripe: ${e.error.localizedMessage}'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/add").then((_) => setState(() {})),
        child: const Icon(Icons.add), ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(child: Text(""),
              decoration: BoxDecoration(color: Colors.blue),),
              ListTile(title: Text("Profile"), onTap: () {Navigator.pushNamed(context, "/profile", arguments: FirebaseAuth.instance.currentUser.uid);},),
              ListTile(title: Text("Edit"), onTap: () {Navigator.pushNamed(context, "/edit");},),
              ListTile(title: Text("Make payment"), onTap: () async {
                await initPaymentSheet(context, email: email, amount: 100);
              },),
               ListTile(title: Text("Sign out"), onTap: () async => _authService.signOutAction(),)
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabPressed,
          currentIndex: _currentIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            label: 'home'
          ),
          BottomNavigationBarItem(
            icon: new Icon(Icons.search),
            label: 'search'
          ),
          ]
        ),
        body: _children[_currentIndex],
    );
  }

}
  
