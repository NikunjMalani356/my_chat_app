import 'package:chat_app/Screen/Login/LoginPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';


import 'Screen/home/HomePage.dart';


void main()async{
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences.getInstance().then((prefs) async {
    await Firebase.initializeApp(
    );
    runApp(MaterialApp(theme: ThemeData(backgroundColor: Colors.black12),home:(prefs?.getBool("login")==true)?HomePage("", ""):LoginPage(),debugShowCheckedModeBanner: false,));
  });
}


class Myapp extends StatelessWidget {
  const Myapp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: LoginPage(),
    );
  }
}
