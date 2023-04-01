import 'dart:io';

import 'package:flutter/material.dart';
import 'package:scheduleme_application/models/chatmodel.dart';
import 'package:scheduleme_application/models/message.dart';
import 'package:scheduleme_application/screens/Chat/own_message.dart';
import 'package:scheduleme_application/screens/Chat/reply_message.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class IndividualScreen extends StatefulWidget {
  const IndividualScreen({super.key, required this.chatModel, required this.sourceChat});
  final ChatModel chatModel;
  final ChatModel sourceChat;

  @override
  State<IndividualScreen> createState() => _IndividualScreenState();
}

class _IndividualScreenState extends State<IndividualScreen> {
  late IO.Socket socket;
  static String serverIP = Platform.isIOS ? "http://localhost" : "http://10.0.2.2";
  TextEditingController _msg = TextEditingController();
  ScrollController _scrollController = ScrollController();
  List<Message> message = [];

  @override
  void initState() {
    super.initState();
    connect();
  }

  void connect() {
    socket = IO.io(
        'https://scheduleme-application.web.app',
        IO.OptionBuilder()
            .setTransports(['websocket']) // set allowed transport protocols
            .disableAutoConnect() // disable auto-connect feature
            .build());

    socket.connect();

    socket.onConnect((_) {
      print('Connected');
      socket.emit('sign-in', widget.sourceChat.chatID);
      socket.on('message', (msg) {
        setMessage('destination', msg['message']);
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    });
    print(socket.connected);
  }

  void sendMessage(String msg, int sourceID, int targetID) {
    setMessage("source", msg);
    socket.emit("message", {"message": msg, "sourceID": sourceID, "targetID": targetID});
  }

  void setMessage(String type, String msg) {
    Message msgModel = Message(
      type: type,
      message: msg,
      time: DateTime.now().toString(),
    );
    setState(() {
      setState(() {
        this.message.add(msgModel);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F5F5),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Color(0xffF5F5F5),
          leadingWidth: 120,
          leading: InkWell(
            onTap: () {
              socket.emit("disconnect", widget.sourceChat.chatID);
              print("disconnected");
              socket.disconnect();
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              size: 28,
              color: Color(0xff000000),
            ),
          ),
          title: Text(
            widget.chatModel.name,
            style: TextStyle(
              fontSize: 20.5,
              fontWeight: FontWeight.bold,
              color: Color(0xff392AAB),
            ),
          ),
        ),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                controller: _scrollController,
                itemCount: this.message.length + 1,
                itemBuilder: (context, index) {
                  var hour = DateTime.now().hour.toString();
                  var minute = DateTime.now().minute.toString();
                  if (hour == "0") hour = "00";
                  if (int.parse(minute) < 10) minute = "0" + minute;

                  if (index == message.length) {
                    return Container(
                      height: 70,
                    );
                  }
                  if (message[index].type == "source") {
                    return OwnMessage(
                      message: this.message[index].message,
                      time: hour + ":" + minute,
                    );
                  } else {
                    return ReplyMessage(
                      message: this.message[index].message,
                      time: hour + ":" + minute,
                    );
                  }
                },
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 80,
                padding: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 60,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: TextFormField(
                            controller: _msg,
                            textAlignVertical: TextAlignVertical.center,
                            keyboardType: TextInputType.multiline,
                            maxLines: 5,
                            minLines: 1,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: "Type a message",
                              contentPadding: EdgeInsets.all(15),
                            ),
                          ),
                        ),
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xff392AAB),
                        child: IconButton(
                          color: Color(0xffF5F5F5),
                          icon: Icon(Icons.send_sharp),
                          iconSize: 18,
                          onPressed: () {
                            _scrollController.animateTo(
                                _scrollController.position.maxScrollExtent,
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeOut);
                            sendMessage(_msg.text, widget.sourceChat.chatID,
                                widget.chatModel.chatID);
                            _msg.clear();
                          },
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
