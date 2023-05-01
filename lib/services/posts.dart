import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twiddle/models/post.dart';
import 'package:twiddle/services/user.dart';
import 'package:quiver/iterables.dart';

class PostService{
  List<PostModel> _postListFromSnapshots(QuerySnapshot snapshot){
    return snapshot.docs.map((e) {
     return PostModel(
      id: e.id,
      text: (e.data() as dynamic)['text'] ?? '',
      creator: (e.data() as dynamic)['creator'] ?? '',
      timestamp: (e.data() as dynamic)['timestamp'] ?? 0,
      likesCount: (e.data() as dynamic)['likesCount'] ?? 0,
       // retweetsCount: (e.data() as dynamic)['retweetsCount'] ?? 0,
        //retweet: (e.data() as dynamic)['retweet'] ?? false,
       // originalId: (e.data() as dynamic)['originalId'] ?? null,
       // ref: e.reference,
     );
    }).toList();
  }

   PostModel _postFromSnapshot(DocumentSnapshot snapshot) {
    return snapshot.exists
        ? PostModel(
            id: snapshot.id,
            text: (snapshot.data() as dynamic)['text'] ?? '',
            creator: (snapshot.data() as dynamic)['creator'] ?? '',
            timestamp: (snapshot.data() as dynamic)['timestamp'] ?? 0,
            likesCount: (snapshot.data() as dynamic)['likesCount'] ?? 0,
            retweetsCount: (snapshot.data() as dynamic)['retweetsCount'] ?? 0,
            retweet: (snapshot.data() as dynamic)['retweet'] ?? false,
            originalId: (snapshot.data() as dynamic)['originalId'] ?? null,
            ref: snapshot.reference,
          )
        : null;
  }
  Future savePost(text, deductCredit) async {
    await FirebaseFirestore.instance.collection("post").add({
      'text' : text,
      'creator': FirebaseAuth.instance.currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'retweet': false
    });

    await FirebaseFirestore.instance.collection("users")
    .doc(FirebaseAuth.instance.currentUser.uid).update({"credits": deductCredit});
  }

   Future reply(PostModel post, String text) async {
    if (text == '') {
      return;
    }
    await post.ref.collection("replies").add({
      'text': text,
      'creator': FirebaseAuth.instance.currentUser.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'retweet': false
    });
  }

  Future likePost(PostModel post, bool current) async {
    print(post.id);
    if (current) {
      post.likesCount = post.likesCount - 1;
      await FirebaseFirestore.instance
          .collection("post")
          .doc(post.id)
          .collection("likes")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .delete();
    }
    if (!current) {
      post.likesCount = post.likesCount + 1;
      await FirebaseFirestore.instance
          .collection("post")
          .doc(post.id)
          .collection("likes")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .set({});
    }
  }

  Future retweet(PostModel post, bool current) async {
    if (current) {
      post.retweetsCount = post.retweetsCount - 1;
      await FirebaseFirestore.instance
          .collection("posts")
          .doc(post.id)
          .collection("retweets")
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .delete();

      await FirebaseFirestore.instance
          .collection("posts")
          .where("originalId", isEqualTo: post.id)
          .where("creator", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .get()
          .then((value) {
        if (value.docs.length == 0) {
          return;
        }
        FirebaseFirestore.instance
            .collection("posts")
            .doc(value.docs[0].id)
            .delete();
      });
      // Todo remove the retweet
      return;
    }
    post.retweetsCount = post.retweetsCount + 1;
    await FirebaseFirestore.instance
        .collection("posts")
        .doc(post.id)
        .collection("retweets")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({});

    await FirebaseFirestore.instance.collection("posts").add({
      'creator': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'retweet': true,
      'originalId': post.id
    });
  }

  Stream<bool> getCurrentUserLike(PostModel post) {
    return FirebaseFirestore.instance
        .collection("post")
        .doc(post.id)
        .collection("likes")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.exists;
    });
  }

  Stream<bool> getCurrentUserRetweet(PostModel post) {
    return FirebaseFirestore.instance
        .collection("posts")
        .doc(post.id)
        .collection("retweets")
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.exists;
    });
  }

  Future<PostModel> getPostById(String id) async {
    DocumentSnapshot postSnap =
        await FirebaseFirestore.instance.collection("posts").doc(id).get();

    return _postFromSnapshot(postSnap);
  }
  
  Stream<List<PostModel>> getPostByUser(uid){
    return FirebaseFirestore.instance.collection("post")
    .where('creator', isEqualTo: uid)
    .snapshots().map(_postListFromSnapshots);
  }

Future<List<PostModel>> getReplies(PostModel post) async {
    QuerySnapshot querySnapshot = await post.ref
        .collection("replies")
        .orderBy('timestamp', descending: true)
        .get();

    return _postListFromSnapshots(querySnapshot);
  }

  Future<List<PostModel>> getFeed() async {
    List<String> usersFollowing = await UserService() //['uid1', 'uid2']
        .getUserFollowing(FirebaseAuth.instance.currentUser.uid);
      print('im here');
          

    var splitUsersFollowing = partition<dynamic>(usersFollowing, 10);
    inspect(splitUsersFollowing);

    List<PostModel> feedList = [];

     for (int i = 0; i < splitUsersFollowing.length; i++) {
      inspect(splitUsersFollowing.elementAt(i));
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('post')
          .where('creator', whereIn: splitUsersFollowing.elementAt(i))
          .orderBy('timestamp', descending: true)
          .get();

      feedList.addAll(_postListFromSnapshots(querySnapshot));
    }

    feedList.sort((a, b) {
      var adate = a.timestamp;
      var bdate = b.timestamp;
      return bdate.compareTo(adate);
    });

    return feedList;
  }
  
}