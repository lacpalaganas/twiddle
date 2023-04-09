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
      appBar: AppBar(title: Text("Home"),
      actions: <Widget>[
        TextButton(onPressed: () async => _authService.signOutAction(), child: const Text("out"))
      ],
      ),
      
    );
  }
}