import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/auth/login_screen.dart';

import '../api/apis.dart';
import '../helper/dailogs.dart';
import '../main.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ProfileScreen({super.key, required this.user});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //global key which will store FOrmState
  final _formKey = GlobalKey<FormState>();
  //? means null ho skta
  String? _image;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: const Text("Profile Screen"),
          ),
          // floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton.extended(
              backgroundColor: Colors.red.shade300,
              onPressed: () async {
                //for showing progress dialog
                Dialogs.showProgressBar(context);

                await APIs.updateActiveStatus(false);

                //sign out from app
                await APIs.auth.signOut().then((value) async {
                  await GoogleSignIn().signOut().then((value) {
                    //for hiding progress dialog
                    Navigator.pop(context);

                    //for  moving to home screen
                    Navigator.pop(context);
                    //otherwise it will store old data and we will be unable to login again
                    APIs.auth=FirebaseAuth.instance;

                    // replacing home screen with login screen
                    Navigator.pushReplacement(context,
                        MaterialPageRoute(builder: (_) => LoginScreen()));
                  });
                });
              },
              icon: const Icon(Icons.logout),
              label: Text('Logout'),
            ),
          ),
          body: Form(
            key: _formKey,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    //for adding some space
                    SizedBox(width: mq.width, height: mq.height * 0.03),

                    //user profile picture
                    // leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                    Stack(
                      children: [
                        //profile picture
                        _image!=null?
                    //local image
                    ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.1),
                           child: Image.file(
                          // add ! so that image null na ho ...we are checking same condition
                             File(_image!),
                          width: mq.height * 0.2,
                  height: mq.height * 0.2,
                  // fit: BoxFit.fill
                             fit: BoxFit.cover,
                           ),
              ):
                        //image from server
                        ClipRRect(
                          borderRadius: BorderRadius.circular(mq.height * 0.1),
                          child: CachedNetworkImage(
                            width: mq.height * 0.2,
                            height: mq.height * 0.2,
                            fit: BoxFit.cover,
                            imageUrl: widget.user.image,
                            // placeholder: (context, url) => CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                const CircleAvatar(
                                    child: Icon(CupertinoIcons.person)),
                          ),
                        ),
                        //edit image button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: MaterialButton(
                              onPressed: () {
                                _showBottomSheet();
                              },
                              elevation: 1,
                              shape: CircleBorder(),
                              color: Colors.white,
                              child: Icon(Icons.edit, color: Colors.blue)),
                        )
                      ],
                    ),

                    //for adding some space
                    SizedBox(height: mq.height * 0.03),

                    //email label
                    Text(widget.user.email,
                        style: TextStyle(color: Colors.black54)),

                    //for adding some space
                    SizedBox(height: mq.height * 0.03),

                    //name input field
                    TextFormField(
                      initialValue: widget.user.name,
                      onSaved: (val) => APIs.me.name = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person, color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Smilee Sidhu',
                          label: Text('Name')),
                    ),

                    //for adding some space
                    SizedBox(height: mq.height * 0.02),

                    //about input field
                    TextFormField(
                      initialValue: widget.user.about,
                      onSaved: (val) => APIs.me.about = val ?? "",
                      validator: (val) => val != null && val.isNotEmpty
                          ? null
                          : 'Required Field',
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.info_outline_rounded,
                              color: Colors.blue),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          hintText: 'eg. Feeling Happy',
                          label: Text('About')),
                    ),

                    //for adding some space
                    SizedBox(height: mq.height * 0.05),

                    //update profile button
                    ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            shape: StadiumBorder(),
                            minimumSize:
                                Size(mq.width * 0.5, mq.height * 0.06)),
                        onPressed: () {
                          // !used because it is not null
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                            APIs.updateUserInfo().then((value) {
                              Dialogs.showSnackbar(
                                  context, 'Profile Updated Successfully!');
                            });
                            print('Inside Validator');
                          } else {}
                        },
                        icon: Icon(
                          Icons.edit,
                          size: 28,
                        ),
                        label: Text(
                          'UPDATE',
                          style: TextStyle(fontSize: 16),
                        ))
                  ],
                ),
              ),
            ),
          )),
    );
  }

  //  bottom sheet for picking a profile pic for user
  void _showBottomSheet() {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            padding: EdgeInsets.only(
                top: mq.height * 0.03, bottom: mq.height * 0.05),
            children: [
              //pick profile pic label
              const Text(
                "Select Profile Picture",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              ),
              // for adding some space
              SizedBox(
                height: mq.height * .02,
              ),
              //buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //pick from gallery button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.gallery);
                        //to reduce server space add imageQuality: in above await statement after gallery,
                        if(image!=null){
                          print('Image path:${image.path} -- MimeType: ${image.mimeType}');
                          setState(() {
                            _image=image.path;
                          });
                          // ! to tell it is not null
                          APIs.updateProfilePic(File(_image!));

                          //for hiding Bottom sheet
                        Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/gallery.png')),
                  //pick from camera button
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          shape: CircleBorder(),
                          fixedSize: Size(mq.width * .3, mq.height * .15)),
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image =
                            await picker.pickImage(source: ImageSource.camera);
                        if(image!=null){
                          print('Image path:${image.path}');
                          setState(() {
                            _image=image.path;
                          });

                          // ! to tell it is not null
                          APIs.updateProfilePic(File(_image!));

                          //for hiding Bottom sheet
                          Navigator.pop(context);
                        }
                      },
                      child: Image.asset('images/camera.png'))
                ],
              )
            ],
          );
        });
  }
}
