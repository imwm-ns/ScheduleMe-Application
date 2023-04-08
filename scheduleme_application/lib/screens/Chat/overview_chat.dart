import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scheduleme_application/models/chatmodel.dart';
import 'package:scheduleme_application/screens/Chat/individual.dart';

class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late CollectionReference collectionReference = fireStore.collection('Profile');
  TextEditingController msgInputController = TextEditingController();

  List<ChatModel> chats = [];
  Map<String, List<dynamic>> mySelectedAccounts = {};
  ChatModel sourceChat = ChatModel(
      name: "", nickname: "", time: "", currentMessage: "", status: "", chatID: 0);

  String email = "";
  bool hasEmail = false;
  var searchAccount = [];

  void initState() {
    super.initState();
    _getCurrentUserData();
    _loadPreviousAccount();
  }

  Future<void> _getCurrentUserData() async {
    final currentUser = await auth.currentUser!;
    if (currentUser != Null) {
      final collectionReference = fireStore.collection('Profile');
      final documentReference = await collectionReference.get();
      documentReference.docs.forEach((element) {
        if (element.exists && element.get('email') != auth.currentUser!.email) {
          final snapShotEmail = element.get("email");
          final snapShotFullName = element.get("full_name");
          final snapShotID = element.get("id");
          final snapShotChatID = element.get("chatID");
          var currentInfo = [
            snapShotEmail.toString(),
            snapShotFullName.toString(),
            snapShotChatID.toString(),
          ];
          searchAccount.add(currentInfo);
        } else {
          var hour = DateTime.now().hour.toString();
          var minute = DateTime.now().minute.toString();
          if (hour == "0") hour = "00";
          if (int.parse(minute) < 10) minute = "0" + minute;
          sourceChat.name = element.get("full_name").toString();
          sourceChat.nickname = element.get("full_name").toString().substring(0, 1);
          sourceChat.currentMessage = "";
          sourceChat.time = hour + ":" + minute;
          sourceChat.status = "online";
          sourceChat.chatID = int.parse(element.get("chatID").toString());
        }
      });
    }
  }

  showAccount(String msg) async {
    for (List account in searchAccount) {
      var hour = DateTime.now().hour.toString();
      var minute = DateTime.now().minute.toString();
      if (hour == "0") hour = "00";
      if (int.parse(minute) < 10) minute = "0" + minute;

      if (account[0] == msg) {
        if (chats.length > 0) {
          for (int i = 0; i < chats.length; i++) {
            if (account[1] != chats[i].name) {
              chats.add(ChatModel(
                name: account[1],
                nickname: account[1].toString().substring(0, 1),
                time: hour + ":" + minute,
                currentMessage: "",
                status: "online",
                chatID: int.parse(account[2]),
              ));
              break;
            }
          }
        } else {
          chats.add(ChatModel(
            name: account[1],
            nickname: account[1].toString().substring(0, 1),
            time: hour + ":" + minute,
            currentMessage: "",
            status: "online",
            chatID: int.parse(account[2]),
          ));
        }
        chats = chats.reversed.toList();
        try {
          List selectedChats = [
            chats[0].name,
            chats[0].status,
            chats[0].time,
            chats[0].chatID.toString()
          ];
          mySelectedAccounts[account[1].toString()] = selectedChats;
          await collectionReference.doc(auth.currentUser!.uid).update({
            "accounts":
                mySelectedAccounts.map((key, value) => MapEntry(key, value.toList()))
          });
        } catch (e) {
          print(e);
        }
        return Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => IndividualScreen(
                      chatModel: chats[0],
                      sourceChat: sourceChat,
                    )));
      }
    }
  }

  void _loadPreviousAccount() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Profile')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      if (doc.exists) {
        final accountsMap =
            Map<String, List<dynamic>>.from(doc.data()!['accounts'] as Map);
        setState(() {
          mySelectedAccounts = accountsMap;
          for (String name in mySelectedAccounts.keys) {
            String accountName = mySelectedAccounts[name]![0];
            String accountStatus = mySelectedAccounts[name]![1];
            String accountTime = mySelectedAccounts[name]![2];
            int accountChatID = int.parse(mySelectedAccounts[name]![3]);
            chats.add(ChatModel(
              name: accountName,
              nickname: accountName.substring(0, 1),
              time: accountTime,
              currentMessage: "",
              status: accountStatus,
              chatID: accountChatID,
            ));
          }
        });
      }
    } catch (e) {
      print('Error loading previous accounts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 40),
              child: Text(
                "Chat",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(top: 30.0, left: 30, right: 30),
              child: TextField(
                cursorColor: Color(0xff88889D),
                controller: msgInputController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Color(0xffF6F6F6),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff88889D),
                      ),
                      borderRadius: BorderRadius.circular(40.0)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xff88889D),
                      ),
                      borderRadius: BorderRadius.circular(40.0)),
                  suffixIcon: Container(
                    margin: const EdgeInsets.only(right: 10),
                    child: IconButton(
                      onPressed: () {
                        email = msgInputController.text;
                        hasEmail = true;
                        showAccount(email);
                        setState(() {});
                        msgInputController.clear();
                      },
                      icon: Icon(Icons.search),
                      iconSize: 28,
                      color: Color(0xffC5BDBD),
                    ),
                  ),
                ),
              ),
            ),
            chats.length == 0
                ? Text("")
                : Expanded(
                    child: ListView.builder(
                    itemCount: chats.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () async {
                          chats[index].time = DateTime.now().toString().substring(11, 16);
                          mySelectedAccounts[chats[index].name] = [
                            chats[index].name,
                            "online",
                            DateTime.now().toString().substring(11, 16),
                            chats[index].chatID.toString(),
                          ];
                          await collectionReference.doc(auth.currentUser!.uid).update({
                            "accounts": mySelectedAccounts
                                .map((key, value) => MapEntry(key, value.toList()))
                          });
                          setState(() {});
                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return IndividualScreen(
                              chatModel: chats[index],
                              sourceChat: sourceChat,
                            );
                          }));
                        },
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xff392AAB),
                          foregroundColor: Colors.white,
                          child: FittedBox(
                            child: Text(chats[index].nickname),
                          ),
                        ),
                        title: Text(chats[index].name),
                        subtitle: Text(chats[index].time),
                      );
                    },
                  ))
          ],
        ),
      ),
      backgroundColor: Color(0xffF5F5F5),
    );
  }
}
