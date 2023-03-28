import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:scheduleme_application/screens/Chat/chat.dart';

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

  String email = "";
  bool hasEmail = false;
  var searchAccount = [];

  void initState() {
    super.initState();
    _getCurrentUserData();
  }

  Future<void> _getCurrentUserData() async {
    final currentUser = await auth.currentUser!;
    if (currentUser != Null) {
      final collectionReference = fireStore.collection('Profile');
      final documentReference = await collectionReference.get();
      documentReference.docs.forEach((element) {
        if (element.exists && element.get("email") != auth.currentUser!.email) {
          final snapShotEmail = element.get("email");
          final snapShotFullName = element.get("full_name");
          final snapShotID = element.get("id");
          var currentInfo = [
            snapShotEmail.toString(),
            snapShotFullName.toString(),
            snapShotID.toString(),
          ];
          searchAccount.add(currentInfo);
        }
      });
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
                        setState(() {});
                        msgInputController.text = "";
                      },
                      icon: Icon(Icons.search),
                      iconSize: 28,
                      color: Color(0xffC5BDBD),
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
              child: hasEmail ? showAccount(email) : Text(""),
            )
          ],
        ),
      ),
      backgroundColor: Color(0xffF5F5F5),
    );
  }

  TextButton showAccount(String msg) {
    for (List account in searchAccount) {
      if (account[0] == msg) {
        return TextButton(
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(
              builder: (context) {
                email = "";
                return const ChatScreen();
              },
            ));
          },
          child: Container(
            child: ListTile(
              leading: CircleAvatar(
                radius: 30,
                backgroundColor: Color(0xff392AAB),
                foregroundColor: Colors.white,
                child: FittedBox(
                  child: Text(account[1].toString().substring(0, 1)),
                ),
              ),
              title: Text(account[1].toString()),
              subtitle: Text(account[2].toString()),
            ),
          ),
        );
      }
    }
    return TextButton(onPressed: () {}, child: Container());
  }
}
