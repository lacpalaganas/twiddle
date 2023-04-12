import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:twiddle/services/posts.dart';

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  final PostService _postService = PostService();
  String text = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Tweet"),
        actions:  <Widget>[
          ElevatedButton(
            onPressed: () async {
              _postService.savePost(text);
              Navigator.pop(context);
            },
             child: const Icon(Icons.add))
        ],
  
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Form(
          child: TextFormField(
            onChanged: (val) {
              setState(() {
                text = val; 
              });
            },
          ),
        ),
      ),
    );
  }
} 