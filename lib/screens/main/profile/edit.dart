import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:twiddle/services/user.dart';


class Edit extends StatefulWidget {
  Edit({Key key}) : super(key: key);

  @override
  _EditState createState() => _EditState();
}

class _EditState extends State<Edit> {
  UserService _userService = UserService();
  File _profileImage;
  File _bannerImage;
  final picker = ImagePicker();
  String name = '';

  Future getImage(int type) async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null && type == 0) {
        _profileImage = File(pickedFile.path);
      }
      if (pickedFile != null && type == 1) {
        _bannerImage = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
              onPressed: () async {
                await _userService.updateProfile(
                    _bannerImage, _profileImage, name);
                Navigator.pop(context);
              },
              child: Text('Save'))
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
            child: Column(
          children: [
            ElevatedButton(
              onPressed: () => getImage(0),
              child: _profileImage == null
                  ? Icon(Icons.person)
                  : Image.file(
                      _profileImage,
                      height: 100,
                    ),
            ),
            ElevatedButton(
              onPressed: () => getImage(1),
              child: _bannerImage == null
                  ? Icon(Icons.person)
                  : Image.file(
                      _bannerImage,
                      height: 100,
                    ),
            ),
            TextFormField(
              onChanged: (val) => setState(() {
                name = val;
              }),
            )
          ],
        )),
      ),
    );
  }
}