import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:we_chat/helper/my_date_util.dart';
import '../api/apis.dart';
import '../helper/dailogs.dart';
import '../main.dart';
import '../models/message.dart';
import 'package:gallery_saver/gallery_saver.dart';

class MessageCard extends StatefulWidget {
  const MessageCard({super.key, required this.message});
  final Message message;

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.message.fromId;
    return InkWell(
        onLongPress: () {
          _showBottomSheet(isMe);
        },
        child: isMe ? _greenMessage() : _blueMessage());
  }

//  sender or another user message
  Widget _blueMessage() {
    // update last read message if sender and receiver are different
    if (widget.message.read.isEmpty) {
      APIs.updateMessageReadStatus(widget.message);
    }

    //after covering with row it will not cover whole row but only upto message last letter
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message content
        //we used flexible instead of expanded
        // because flexible cover only space which is required
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.01, horizontal: mq.width * 0.04),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlueAccent),
                color: const Color.fromARGB(255, 221, 245, 255),
                //making border curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomRight: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                //show image
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70)),
                  ),
          ),
        ),

        //  message time
        Padding(
          padding: EdgeInsets.only(right: mq.width * 0.04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.message.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
  }

//  our or user message
  Widget _greenMessage() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        //message time
        Row(
          children: [
            // for adding some space
            SizedBox(width: mq.width * 0.04),

            //double tick blue icon for message read
            if (widget.message.read.isNotEmpty)
              const Icon(Icons.done_all_rounded, color: Colors.blue, size: 20),

            //for adding some space
            const SizedBox(width: 2),

            // sent time
            Text(
              MyDateUtil.getFormattedTime(
                  context: context, time: widget.message.sent),
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ],
        ),
        //message content
        //we used flexible instead of expanded
        // because flexible cover only space which is required
        Flexible(
          child: Container(
            padding: EdgeInsets.all(widget.message.type == Type.image
                ? mq.width * 0.03
                : mq.width * 0.04),
            margin: EdgeInsets.symmetric(
                vertical: mq.height * 0.01, horizontal: mq.width * 0.04),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.lightGreen),
                color: const Color.fromARGB(255, 218, 255, 176),
                //making border curved
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.message.type == Type.text
                ?
                //show text
                Text(
                    widget.message.msg,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  )
                //show image
                : ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CachedNetworkImage(
                        imageUrl: widget.message.msg,
                        placeholder: (context, url) => Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: const CircularProgressIndicator(
                                  strokeWidth: 2),
                            ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.image, size: 70)),
                  ),
          ),
        ),
      ],
    );
  }

  //  bottom sheet for modifying message details
  void _showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * 0.015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.message.type == Type.text
                  ?
                  //copy option
                  _OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.message.msg))
                            .then((value) {
                          //for hiding bottom sheet
                          Navigator.pop(context);
                          Dialogs.showSnackbar(context, 'Text Copied');
                        });
                      })
                  : //save image
                  _OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          print('Image URL: ${widget.message.msg}');
                          await GallerySaver.saveImage(widget.message.msg,
                                  albumName: 'WeChat')
                              .then((success) {
                            //for hiding bottom sheet
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showSnackbar(
                                  context, 'Image Successfully Saved!');
                            }
                          });
                        } catch (e) {
                          print('ErrorWhileSavingImage: $e');
                        }
                      }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * 0.04,
                ),

              //  edit message
              if (widget.message.type == Type.text && isMe)
                _OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Navigator.pop(context);

                      _showMessageUpdateDailog();
                    }),

              //  delete option
              if (isMe)
                _OptionItem(
                    icon: const Icon(Icons.delete, color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.message).then((value) {
                        //for hiding bottom sheet
                        Navigator.pop(context);
                        Dialogs.showSnackbar(context, 'message Deleted');
                      });
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * 0.04,
              ),

              //  sent time
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      'Send At: ${MyDateUtil.getMessageTime(context: context, time: widget.message.sent)}',
                  onTap: () {}),

              //  Seen time(read)
              _OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.message.read.isEmpty
                      ? "Seen -"
                      : 'Seen: ${MyDateUtil.getMessageTime(context: context, time: widget.message.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

//  dialog for updating message content
  void _showMessageUpdateDailog() {
    String updatedMsg = widget.message.msg;
    showDialog(
        context: context,
        builder: (_) => AlertDialog(
          contentPadding: const EdgeInsets.only(left:24,right: 24,top: 20,bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              // title
              title: const Row(
                children: [
                  Icon(Icons.message_rounded, color: Colors.blue, size: 28),
                  Text(' Update Message')
                ],
              ),
              //content
              content: TextFormField(
                initialValue: updatedMsg,
                //acc to content update it
                maxLines: null,
                onChanged: (value)=>updatedMsg=value,
                decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(15))),
              ),
            //actions
          actions: [
            //cancel button
            MaterialButton(onPressed: (){
              Navigator.pop(context);
            },child: const Text('Cancel',style: TextStyle(color: Colors.blue,fontSize: 16),),),
            //update button
            MaterialButton(onPressed: (){
              Navigator.pop(context);
              APIs.updateMessage(widget.message, updatedMsg);
            },child: const Text('Update',style: TextStyle(color: Colors.blue,fontSize: 16),),)
          ],
            ));
  }
}

class _OptionItem extends StatelessWidget {
  //so that we call fn acc to our requirement simply by calling _optionaltem
  final Icon icon;
  final String name;
  //user to pass on tap content
  final VoidCallback onTap;

  //to get named paramters we use {}
  const _OptionItem(
      {required this.icon, required this.name, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Padding(
        padding: EdgeInsets.only(
            left: mq.width * 0.05,
            top: mq.height * .015,
            bottom: mq.height * .015),
        child: Row(
          children: [
            icon,
            Flexible(
                child: Text(
              '      $name',
              style: const TextStyle(
                  color: Colors.black87, letterSpacing: 0.5, fontSize: 16),
            ))
          ],
        ),
      ),
    );
  }
}
