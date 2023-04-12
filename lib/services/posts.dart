import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twiddle/models/post.dart';

class PostService{
  List<PostModel> _postListFromSnapshots(QuerySnapshot snapshot){
    return snapshot.docs.map((e) {
     return PostModel(
      id: e.id,
      text: (e.data() as dynamic)['text'] ?? '',
      creator: (e.data() as dynamic)['creator'] ?? '',
      timestamp: (e.data() as dynamic)['timestamp'] ?? 0,
     );
    }).toList();
  }
  Future savePost(text) async {
    await FirebaseFirestore.instance.collection("post").add({
      'text' : text,
      'creator': FirebaseAuth.instance.currentUser?.uid,
      'timestamp': FieldValue.serverTimestamp()
    });
  }

  Stream<List<PostModel>> getPostByUser(uid){
    return FirebaseFirestore.instance.collection("post")
    .where('creator', isEqualTo: uid)
    .snapshots().map(_postListFromSnapshots);
  }
}