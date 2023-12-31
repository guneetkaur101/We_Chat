import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:we_chat/helper/dailogs.dart';
import 'package:we_chat/screens/home_screen.dart';

import '../../api/apis.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget{
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
 bool _isAnimate=false;
  @override
  void initState() {
       super.initState();
       Future.delayed(const Duration(milliseconds:500 ),(){
         setState(() {
           _isAnimate=true;
         });
       });
  }

  _handledGoogleBtnClick(){
    Dialogs.showProgressBar(context);
    _signInWithGoogle().then((user) async{
      Navigator.pop(context);
      if(user != null) {
        log('\nUser: ${user.user}');
        log('\nUserAdditionalInfo: ${user.additionalUserInfo}');

        if ((await APIs.userExits())) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (_) => HomeScreen()));
        }
        else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (_) => HomeScreen()));
          });
        }
      }
    } );
  }

 Future<UserCredential?> _signInWithGoogle() async {
   try {
     await InternetAddress.lookup('google.com');
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
     return await APIs.auth.signInWithCredential(credential);
   }
   catch (e) {
     log('\n_signInWithGoogle : $e');
     Dialogs.showSnackbar(context, "Something Went Wrong Check Internet Connection!");
     return null;
   }
 }
  //signout fn
  //_signOut() async{
  //await FirebaseAuth.instance.signOut() ;
 //await GoogleSignIn().signOut();
 //}
 @override
  Widget build(BuildContext context) {
    // mq= MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:false ,
        title:const Text(" Welcome to WeChat"),

      ),
      body: Stack(children: [
        AnimatedPositioned(
          top: mq.height*.15,
            right:_isAnimate? mq.width*.25: -mq.width*.5,
            width: mq.width*.5,
            duration: const Duration(seconds:1 ),
            child: Image.asset('images/whatsapp.png')),
        Positioned(
            bottom: mq.height* .15,
            left: mq.width* .05,
            width: mq.width* .9,
            height: mq.height*0.07,
            child: ElevatedButton.icon(
                style:ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 223, 255, 187),
                shape: const StadiumBorder(),
                elevation: 1) ,
                onPressed: (){
                  // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
                  _handledGoogleBtnClick();
                }, icon: Image.asset('images/search.png',height: mq.height*.03), label:RichText(text: const TextSpan(
              style: TextStyle(color: Colors.black,fontSize: 16),
              children: [
                TextSpan(text: "Login with "),
                TextSpan(text: "Google",style: TextStyle(fontWeight: FontWeight.bold))
              ],
            ),))),

      ]),


    );
  }
}