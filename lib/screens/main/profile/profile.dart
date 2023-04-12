import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:twiddle/screens/main/posts/list.dart';
import 'package:twiddle/services/posts.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  PostService _postService = PostService();
  @override
  Widget build(BuildContext context) {
    return StreamProvider.value(
      value: _postService.getPostByUser(
        FirebaseAuth.instance.currentUser?.uid), 
        initialData: null,
        child: Scaffold(
          body: Container(
            child: ListPosts(),
          ),
        ),);
  }
}