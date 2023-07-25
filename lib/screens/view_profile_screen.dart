import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:we_chat/helper/my_date_util.dart';
import 'package:we_chat/models/chat_user.dart';

import '../main.dart';

class ViewProfileScreen extends StatefulWidget {
  final ChatUser user;
  const ViewProfileScreen({super.key, required this.user});
  @override
  State<ViewProfileScreen> createState() => _ViewProfileScreenState();
}

//view profile screen -->to view profile of user
class _ViewProfileScreenState extends State<ViewProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.user.name)),
          floatingActionButton:  Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Joined on: ',
                  style: TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                      fontSize: 15)),
              Text(MyDateUtil.getLastMessageTime(context: context, time: widget.user.createdAt,showYear: true),
                  style: TextStyle(color: Colors.black54, fontSize: 15)),
            ],
          ),

          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  //for adding some space
                  SizedBox(width: mq.width, height: mq.height * 0.03),

                  //user profile picture
                  // leading: CircleAvatar(child: Icon(CupertinoIcons.person)),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.1),
                    child: CachedNetworkImage(
                      width: mq.height * 0.2,
                      height: mq.height * 0.2,
                      fit: BoxFit.cover,
                      imageUrl: widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),

                  //for adding some space
                  SizedBox(height: mq.height * 0.03),

                  //email label
                  Text(widget.user.email,
                      style: TextStyle(color: Colors.black87)),

                  //for adding some space
                  SizedBox(height: mq.height * 0.02),

                  //user about
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('About: ',
                          style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: 15)),
                      Text(widget.user.about,
                          style: TextStyle(color: Colors.black54,fontSize: 15)),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
