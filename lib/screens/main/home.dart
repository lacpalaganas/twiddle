import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:twiddle/services/auth.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return Scaffold(
      appBar: AppBar(title: const Text("Home"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, "/add"),
        child: const Icon(Icons.add), ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(child: Text("Drawer Header"),
              decoration: BoxDecoration(color: Colors.blue),),
              ListTile(title: Text("Profile"), onTap: () {Navigator.pushNamed(context, "/profile");},),
              ListTile(title: Text("Edit"), onTap: () {Navigator.pushNamed(context, "/edit");},),
              ListTile(title: Text("Sign out"), onTap: () async => _authService.signOutAction(),)
            ],
          ),
        ),
    );
  }
}