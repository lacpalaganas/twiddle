import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:provider/provider.dart';
import 'package:twiddle/models/user.dart';
import 'package:twiddle/screens/auth/sign_up.dart';
import 'package:twiddle/screens/main/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});
 
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel?>(context);
    // ignore: unnecessary_null_comparison
    print(user);
    if (user == null){
      return const SignUp();
    }
    return const Home();
  }
}