import 'dart:collection';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:twiddle/services/utils.dart';

class UserService{
  UtilsService _utilsService = UtilsService();
  Future<void> updateProfile(File _bannerImage, File _profileImage, String userName) async {
   
    String bannerImageUrl = '';
    String profileImageUrl = '';
   
    if(_bannerImage != null ){
      bannerImageUrl = _utilsService.uploadFile(_bannerImage, 'user/profile/${FirebaseAuth.instance.currentUser?.uid}/banner') as String;
    }

    if(_profileImage != null ){
      profileImageUrl = _utilsService.uploadFile(_profileImage, 'user/profile/${FirebaseAuth.instance.currentUser?.uid}/profile') as String;
    }
    Map<String, Object> data = new HashMap();
    if(userName != '') data['userName'] = userName;
    if(bannerImageUrl != '') data['bannerImageUrl'] = bannerImageUrl;
    if(profileImageUrl != '') data['profileImageUrl'] = profileImageUrl;


    await FirebaseFirestore.instance.collection('users')
    .doc(FirebaseAuth.instance.currentUser?.uid).update(data);

  }
}