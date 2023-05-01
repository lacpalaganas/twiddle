import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twiddle/services/auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';


class Home extends StatefulWidget {
  const Home({super.key});

@override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
   Map<String, dynamic>? paymentIntent;
   var credits = "";
@override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
   
    return Scaffold(
      appBar: AppBar(title: const Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/add").then((_) => setState(() {})),
        child: const Icon(Icons.add), ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(child: Text("Drawer Header"),
              decoration: BoxDecoration(color: Colors.blue),),
              ListTile(title: Text("Profile"), onTap: () {Navigator.pushNamed(context, "/profile");},),
              ListTile(title: Text("Edit"), onTap: () {Navigator.pushNamed(context, "/edit");},),
              ListTile(title: Text("Make payment"), onTap: () async => await makePayment(),),
               ListTile(title: Text("Sign out"), onTap: () async => _authService.signOutAction(),)
            ],
          ),
        ),
    );
  }

  Future<void> makePayment() async {
    try {
      paymentIntent = await createPaymentIntent('100', 'USD');

      //STEP 2: Initialize Payment Sheet
      await Stripe.instance
          .initPaymentSheet(
              paymentSheetParameters: SetupPaymentSheetParameters(
                  paymentIntentClientSecret: paymentIntent![
                      'client_secret'], //Gotten from payment intent
                  style: ThemeMode.dark,
                  merchantDisplayName: 'Ikay'))
          .then((value) {});

      //STEP 3: Display Payment sheet
      displayPaymentSheet();
    } catch (err) {
      throw Exception(err);
    }
  }

  displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((value) {
        showDialog(
            context: context,
            builder: (_) => AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 100.0,
                      ),
                      SizedBox(height: 10.0),
                      Text("Payment Successful!"),
                    ],
                  ),
                ));

        paymentIntent = null;
         FirebaseFirestore.instance.collection("user_credits").add({
      'id': FirebaseAuth.instance.currentUser?.uid,
      'credits': credits
    });
      }).onError((error, stackTrace) {
        throw Exception(error);
      });
    } on StripeException catch (e) {
      print('Error is:---> $e');
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                Text("Payment Failed"),
              ],
            ),
          ],
        ),
      );
    } catch (e) {
      print('$e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      //Request body
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
      };

      //Make post request to Stripe
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      return json.decode(response.body);
    } catch (err) {
      throw Exception(err.toString());
    }
  }

  calculateAmount(String amount) {
    final calculatedAmout = (int.parse(amount)) * 100;
    credits = calculatedAmout.toString();
    return calculatedAmout.toString();
  }
}
  
