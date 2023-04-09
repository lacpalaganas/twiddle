import 'package:flutter/material.dart';
import 'package:twiddle/services/auth.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final AuthService _authService = AuthService();
  String email = '';
  String password = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 8,
        title: const Text("Sign Up"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
        child: Form(
            child: Column(
          children: [
            TextFormField(
              onChanged: (val) => setState(() {
                email = val;
              }),
            ),
            TextFormField(
              onChanged: (val) => setState(() {
                password = val;
              }),
            ),
            ElevatedButton(
                child: const Text("Sign up"),
                onPressed: () async => {_authService.signUpAction(email, password)}),
            ElevatedButton(
                child: const Text("Sign in"),
                onPressed: () async => {
                  _authService.signInAction(email, password)}),
          ],
        )),
      ),
    );
  }
}
