import 'dart:developer';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat/api/apis.dart';
import 'package:we_chat/screens/home_screen.dart';

import '../../main.dart';
import 'auth/login_screen.dart';

class SplashScreen extends StatefulWidget{
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds:2 ),(){
      //exit full-screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.transparent));
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor:Colors.white,statusBarColor:Colors.white  ));
      if(APIs.auth.currentUser!= null){
        log('\nUser: ${APIs.auth.currentUser}');
        // log('\nUserAdditionalInfo: ${FirebaseAuth.instance.currentUser}');
        // navigate to home screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>HomeScreen()));
      }
      else{
        // navigate to Login screen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=>LoginScreen()));
      }

    });
  }
  @override
  Widget build(BuildContext context) {
    mq= MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading:false ,
        title:const Text(" Welcome to WeChat"),

      ),
      body: Stack(children: [
        Positioned(
            bottom: mq.height*.15,
            width: mq.width,
            child:Text('Developed by Sidhu with ❤ ',textAlign: TextAlign.center,
                style: TextStyle(
                fontSize: 20,
                color: Colors.black87,
                  letterSpacing: 2.0,),
            )
      ),



            //        wavy animation
        //     child: DefaultTextStyle(
        //     style: TextStyle(
        //     fontSize: 20,
        //     color: Colors.black87,
        //      letterSpacing: 2.0,
        // ),
        //     child: AnimatedTextKit(repeatForever: true, animatedTexts: [
        //     WavyAnimatedText('Developed by Guneet with ❤ ',textAlign: TextAlign.center)
        //   ],
        //   ),
    // ),
    //     ),

      ]),


    );
  }
}