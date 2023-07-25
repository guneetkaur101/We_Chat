// import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:we_chat/screens/view_profile_screen.dart';

import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/chat_user.dart';
import '../models/message.dart';
import '../widgets/message_card.dart';

class ChatScreen extends StatefulWidget {
  final ChatUser user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //for storing all messages
  List<Message> _list = [];

  //for handling message text  changes
  final _textController = TextEditingController();

  //Showemoji-->For storing value of showing or hiding emoji
  //Isuploading--> for checking if image is uploading or not?
  bool _showEmoji = false, _isUploading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          //if emojis are shown &back button is pressed then hide emojis
          // or else simple close current screen on back button call
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              //false do nothing
              return Future.value(false);
            } else {
              //  perform normal back operation
              return Future.value(true);
            }
          },
          child: Scaffold(
            //app bar
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),

            backgroundColor: const Color.fromARGB(255, 234, 248, 255),
            //body
            body: Column(
              children: [
                //because streamBuilder is not taking all space
                // so use Expanded so that it can all space
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          // return const Center(child: CircularProgressIndicator());
                          return const SizedBox();
                        //    if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          //it will not be null since we have already added one item in firestore
                          // print('Data:${jsonEncode(data![0].data())}');
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];

                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse:
                                    true, //so that chat last seen is shown and we can scroll up to see previous message
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: mq.height * 0.01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return MessageCard(
                                    message: _list[index],
                                  );
                                });
                          } else {
                            return Center(
                                child: Text(
                              "Say Hi! 👋",
                              style: TextStyle(fontSize: 20),
                            ));
                          }
                      }
                    },
                  ),
                ),

                //progress indicator for showing uploading
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),
                //chat input feild
                _chatInput(),

                //show emojis on keyboard emoji button click and vice versa
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * 0.35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 184, 210, 239),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //make fn which will return widget
  //appbar widget
  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_)=>ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              //it will not be null since we have already added one item int firestore
              // print('Data:${jsonEncode(data![0].data())}');

              final list =
                  data?.map((e) => ChatUser.fromJson(e.data())).toList() ?? [];

              return Row(
                children: [
                  //back button
                  IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: Colors.black54,
                      )),
                  //user profile picture
                  ClipRRect(
                    borderRadius: BorderRadius.circular(mq.height * 0.3),
                    child: CachedNetworkImage(
                      width: mq.height * 0.05,
                      height: mq.height * 0.05,
                      imageUrl:
                          list.isNotEmpty ? list[0].image : widget.user.image,
                      // placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const CircleAvatar(
                          child: Icon(CupertinoIcons.person)),
                    ),
                  ),
                  //for adding some space
                  const SizedBox(
                    width: 10,
                  ),
                  //username and last seen time
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    //by default it is at centre that's why we are getting last seen starting before user name
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //user name
                      Text(
                        list.isNotEmpty ? list[0].name : widget.user.name,
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500),
                      ),

                      //for adding some space
                      const SizedBox(
                        height: 2,
                      ),
                      //last seen time of user
                      Text(
                        list.isNotEmpty
                            ? list[0].isOnline
                                ? 'Online'
                                : MyDateUtil.getLastActiveTime(context: context, lastActive: list[0].lastActive)
                            : MyDateUtil.getLastActiveTime(context: context, lastActive: widget.user.lastActive),
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      )
                    ],
                  )
                ],
              );
            }));
  }

//  bottom chat input field
  Widget _chatInput() {
    //card will provide elevation white at bg
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * 0.01, horizontal: mq.width * 0.025),
      child: Row(
        //input field & button
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  //emoji button
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        color: Colors.blueAccent,
                        size: 25,
                      )),

                  Expanded(
                      child: TextField(
                    controller: _textController,
                    //so that it doest not expand like (vdfvvxvvxvvv) instead
                    // like this in  textfeild
                    // (ddvfv
                    // vffvfcv
                    // fvdvv)
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    onTap: () {
                      if (_showEmoji) setState(() => _showEmoji = !_showEmoji);
                    },
                    decoration: const InputDecoration(
                        hintText: 'Type Something...',
                        hintStyle: TextStyle(color: Colors.blueAccent),
                        border: InputBorder.none),
                  )),

                  //pick image from gallery button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick multiple images
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);

                        //uploading & sending image one by one
                        for (var i in images) {
                          print('IMAGE PATH:${i.path}');
                          setState(() => _isUploading = true);
                          // ! to tell it is not null
                          await APIs.sendChatImage(widget.user, File(i.path));
                          setState(() => _isUploading = false);
                        }
                        // if (images.isNotEmpty) {
                        //   print('Image path:${images.path}');
                        //  }
                      },
                      icon: const Icon(
                        Icons.image,
                        color: Colors.blueAccent,
                        size: 26,
                      )),

                  //take image from camera button
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          print('Image path:${image.path}');
                          setState(() => _isUploading = true);

                          // ! to tell it is not null
                          await APIs.sendChatImage(
                              widget.user, File(image.path));
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          color: Colors.blueAccent, size: 26)),
                  //for adding some space
                  SizedBox(
                    width: mq.width * 0.02,
                  ),
                ],
              ),
            ),
          ),

          //  send message button
          MaterialButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                if(_list.isEmpty){
                  //on first message (add user to my_user collection of chat user)
                  APIs.sendFirstMessage(widget.user, _textController.text, Type.text);
                }
                else {
                  //simply send message
                  APIs.sendMessage(widget.user, _textController.text, Type.text);
                }
                //to clear message after sending
                _textController.text = '';
              }
              //   else{}
            },
            //because it is covering more width
            minWidth: 0,
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 5, left: 10),
            shape: CircleBorder(),
            color: Colors.green,
            child: Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 28,
            ),
          )
        ],
      ),
    );
  }
}
