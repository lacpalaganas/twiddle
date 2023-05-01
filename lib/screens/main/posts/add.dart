import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:twiddle/services/posts.dart';


class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
   @override
  void initState(){
    
    print("init");
    super.initState();
    getUserCredit();
    
  }
  
 final usersRef = FirebaseFirestore.instance.collection("users");
  
  final PostService _postService = PostService();
  String text = "";

  final textController = TextEditingController();
   int credits = 1;
   int charLength = 0;
  
   int deductCredits = 0;
  final currentUser = FirebaseAuth.instance.currentUser?.uid;
    getUserCredit () async{
   final DocumentSnapshot doc =  await usersRef.doc(currentUser).get();
   // usersRef.doc(currentUser).get().then((DocumentSnapshot doc){
     // credits = doc.get('credits');
    //});
    setState(() {
       credits = doc.get('credits');
    });
  
   if(credits == null){
    credits = 0;
   }
   print("credits $credits");
   
  }
  @override
  Widget build(BuildContext context) {
    int maxLength = credits;
     dynamic _card = "";
   
    // Future maxLength = _postService.getUserCredit();
    // print(maxLength);
      return Scaffold(
      appBar: AppBar(
        title: const Text("Add Tweet"),
        actions:  <Widget>[
          ElevatedButton(
            onPressed: () async {
                deductCredits = credits - charLength;
                //print("deduct $deductCredits");
             _postService.savePost(text, deductCredits);
              Navigator.pop(context);
            },
             child: const Icon(Icons.add))
        ],
  
      ),
      body: Column(
        children:[ Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          child:  Form(
            child: TextFormField(
            controller: textController,
              maxLength: maxLength,
              onChanged: (val) {
                setState(() {
                  text = val; 
                   charLength = val.length;
                  print(charLength);
                });
                
              },
              
            ),
            
          
            
          ),
          
        ),
        CardField(
    onCardChanged: (card) {
        setState(() {
           _card = card;
        });
    },    
),

      ]),
      
      
    );
    
  }
} 