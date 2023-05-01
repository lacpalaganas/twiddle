import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:twiddle/screens/main/posts/lists.dart';
import 'package:twiddle/services/posts.dart';

class Feed extends StatefulWidget {
  const Feed({Key key}) : super(key: key);

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  PostService _postService = PostService();
  @override
  Widget build(BuildContext context) {
    return FutureProvider.value(
      value: _postService.getFeed(), 
      child: Scaffold(
        body: ListPosts(),
      ),);
  }
}