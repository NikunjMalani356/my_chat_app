import 'package:chat_app/Screen/home/HomePage.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Componants/textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  FirebaseAuth auth = FirebaseAuth.instance;

  bool logintemp =false;
  FirebaseDatabase database = FirebaseDatabase.instance;

  TextEditingController name=TextEditingController();
  TextEditingController mobile=TextEditingController();
   SharedPreferences? prefs;

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    get();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Name, email address, and profile photo URL
      String name = user.displayName.toString();
      String email = user.email.toString();


      WidgetsBinding.instance.addPostFrameCallback((_){

        Navigator.push(context, MaterialPageRoute(builder: (context) {
          return HomePage(name, email);
        },));
      });

    }
  }
  @override
  get()
  async {
    prefs = await SharedPreferences.getInstance();
  }
  void authentication(){
    if((name.text!=null && mobile.text!=null)) {
      logintemp = true;
      print("starting ${prefs?.getBool("login")}");

      prefs!.setBool("login",true);
      prefs!.setString("name",name.text);
      prefs!.setString("number",mobile.text);

      showDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: Text("login succsessful"),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) {
                return HomePage(name.text,mobile.text);
              },));
            }, child: Text("ok"))
          ],
        );
      },);
    }
    else
    {
      print("id wrong");
      showDialog(context: context, builder: (context) {
        return CupertinoAlertDialog(
          title: Text("Login Fail"),
          actions: [
            TextButton(onPressed: () {
              Navigator.pop(context);
            }, child: Text("ok"))
          ],
        );
      },);

    }

  }
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login"),
      ),
      body: ListView(
        children: [
          Mytextfield(controller: name, hintText: "name", obscuretext: false),
          Mytextfield(controller: mobile, hintText: "mobile", obscuretext: false),
          ElevatedButton(onPressed: () async {
           setState(() {
             print("starting ${prefs?.getBool("login")}");
             prefs?.setBool("login",true);

             authentication();

           });
          }, child: Text("Add")),




          ElevatedButton(onPressed: () {
            signInWithGoogle().then( (value) {
              print(value);
              print(value.user!.displayName);
              print(value.user!.email);

              prefs!.setBool("login",true);
              prefs!.setString("name",value.user!.displayName.toString());
              prefs!.setString("number",value.user!.email.toString());
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return HomePage(value.user!.displayName.toString(),value.user!.email.toString());
              },));
            });

          }, child: Text(" Google login")),

        ],
      ),
    );
  }
}
