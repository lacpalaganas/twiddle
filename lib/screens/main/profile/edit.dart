import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:image_picker/image_picker.dart';

class Edit extends StatefulWidget {
  const Edit({super.key});

  @override
  State<Edit> createState() => _EditState();
}

class _EditState extends State<Edit> {
  var _profileImage;
  var _bannerImage;
  final picker = ImagePicker();
  var name = '';

  Future getImage(int type) async{
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if(pickedFile != null && type == 0){
        _profileImage = File(pickedFile.path);
      }

      if(pickedFile != null && type == 1){
        _bannerImage = File(pickedFile.path);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(onPressed: null, child: Text("save"))
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(child: Column(
          
          children: [
            ElevatedButton(onPressed: () => getImage(0), 
            child: _profileImage == null ? Icon(Icons.person) : Image.file(_profileImage, height: 100,),
             ),
              ElevatedButton(onPressed: () => getImage(1), 
            child: _bannerImage == null ? Icon(Icons.person) : Image.file(_bannerImage, height: 100,),
             )
            ,TextFormField(
            onChanged: (val) =>setState(() {
              name = val;
            }),)],
        )),
      ),
    );
  }
}