// import 'dart:convert';
// import 'dart:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat/models/chat_user.dart';
import 'package:we_chat/screens/profile_screen.dart';
import 'package:we_chat/widgets/chat_user_card.dart';
import '../api/apis.dart';
import '../helper/dailogs.dart';
import '../main.dart';

//home screen-->where all available contacts are shown
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  //for storing all users
  List<ChatUser> _list = [];

  //for storing searched items
  final List<ChatUser> _searchList = [];

  // for storing search status
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    APIs.getSelfInfo();
    // //for setting user status to active
    // APIs.updateActiveStatus(true);
    // screen is either paused inactive or resumed
    //for updating user active status according to lifestyle events
    //resume--> active or online
    //pause--> inactive or offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      print('MESSAGE:$message');

      if (APIs.auth.currentUser != null) {
        if (message.toString().contains('pause')) {
          APIs.updateActiveStatus(false);
        }

        if (message.toString().contains('resume')) {
          APIs.updateActiveStatus(true);
        }
      }
      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      //for hiding keyboard when tap is detected on screen
      onTap: () => FocusScope.of(context).unfocus(),

      // willpopscope is only applicable to scaffold it is applied on or current screen
      child: WillPopScope(
        //if search is on &back button is pressed then close search
        // or else simple close current screen on back button call
        onWillPop: () {
          if (_isSearching) {
            setState(() {
              _isSearching = !_isSearching;
            });
            //false do nothing
            return Future.value(false);
          } else {
            //  perform normal back operation
            return Future.value(true);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            leading: const Icon(CupertinoIcons.home),
            title: _isSearching
                ? TextField(
                    decoration: const InputDecoration(
                        border: InputBorder.none, hintText: 'Name,Email,...'),
                    autofocus: true,
                    style: const TextStyle(fontSize: 17, letterSpacing: .5),
                    // when search text changes then updated search list
                    onChanged: (val) {
                      //  search logic
                      _searchList.clear();
                      for (var i in _list) {
                        if (i.name.toLowerCase().contains(val.toLowerCase()) ||
                            i.email.toLowerCase().contains(val.toLowerCase())) {
                          _searchList.add(i);
                          setState(() {
                            _searchList;
                          });
                        }
                      }
                    },
                  )
                : Text("WeChat"),
            actions: [
              //search user button
              IconButton(
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                    });
                  },
                  icon: Icon(_isSearching
                      ? CupertinoIcons.clear_circled_solid
                      : Icons.search)),
              //more feature button
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ProfileScreen(user: APIs.me)));
                  },
                  icon: const Icon(Icons.more_vert))
            ],
          ),

          //floating button to add new user
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton(
              onPressed: ()  {
                _addChatUserDailog();
              },
              child: const Icon(Icons.add_comment_rounded),
            ),
          ),

          body: StreamBuilder(
            stream: APIs.getMyUsersId(),

              //get id of only known users

              builder:(context,snapshot){
                switch (snapshot.connectionState) {
                //if data is loading
                  case ConnectionState.waiting:
                  case ConnectionState.none:
                    // return const Center(child: CircularProgressIndicator());

                //    if some or all data is loaded then show it
                  case ConnectionState.active:
                  case ConnectionState.done:
               return StreamBuilder(
                //if we have a list then send it to getallusers
                //else pass an empty string
                stream: APIs.getAllUsers( snapshot.data?.docs.map((e) => e.id).toList() ??
                    []),

                //get only those user,whose id's are provided
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                  //if data is loading
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return const Center(child: CircularProgressIndicator());

                  //    if some or all data is loaded then show it
                    case ConnectionState.active:
                    case ConnectionState.done:
                      final data = snapshot.data?.docs;
                      _list =
                          data?.map((e) => ChatUser.fromJson(e.data())).toList() ??
                              [];

                      if (_list.isNotEmpty) {
                        return ListView.builder(
                            itemCount:
                            _isSearching ? _searchList.length : _list.length,
                            padding: EdgeInsets.only(top: mq.height * 0.01),
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              // return Text("Name:${list[index]}");
                              return ChatUserCard(
                                  user: _isSearching
                                      ? _searchList[index]
                                      : _list[index]);
                            });
                      } else {
                        return const Center(
                            child: Text(
                              "No Connections Found!",
                              style: TextStyle(fontSize: 20),
                            ));
                      }
                  }
                },
              );
            }

          })
        ),
      ),
    );
  }
  //  for adding new chat user
  void _addChatUserDailog() {
    String email = '';
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(left:24,right: 24,top: 20,bottom: 10),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          // title
          title: const Row(
            children: [
              Icon(Icons.person_add, color: Colors.blue, size: 28),
              Text('  Add User')
            ],
          ),
          //content
          content: TextFormField(

            //acc to content update it
            maxLines: null,
            onChanged: (value)=>email=value,
            decoration: InputDecoration(
              hintText: 'Email Id',
                prefixIcon: const Icon(Icons.email,color: Colors.blue,),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
          ),
          //actions
          actions: [
            //cancel button
            MaterialButton(onPressed: (){
              //hide alert dailog
              Navigator.pop(context);
            },child: const Text('Cancel',style: TextStyle(color: Colors.blue,fontSize: 16),),),
            //add button
            MaterialButton(onPressed: () async {
              Navigator.pop(context);
              if(email.isNotEmpty) {
                await APIs.addChatUser(email).then((value){
                  if(!value){
                    Dialogs.showSnackbar(context, 'User does not Exists!');
                  }
                });
              }
            },child: const Text('Add',style: TextStyle(color: Colors.blue,fontSize: 16),),)
          ],
        ));
  }

}
