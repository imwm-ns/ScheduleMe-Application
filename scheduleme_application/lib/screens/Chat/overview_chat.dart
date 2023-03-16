import 'package:cloud_firestore/cloud_firestore.dart';
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
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;
  late CollectionReference collectionReference = fireStore.collection('Profile');
  TextEditingController msgInputController = TextEditingController();
  String nameKey = "";

  void initState() {
    super.initState();
  }

  Future<List<Object?>> _getData() async {
    QuerySnapshot querySnapshot = await collectionReference.get();
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    return allData;
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
                        searchClient(msgInputController.text);
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
            Container(
              child: Expanded(
                child: StreamBuilder(
                  stream: collectionReference.snapshots(),
                  builder: ((context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return ListView(
                      children: getUserItems(snapshot),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xffF5F5F5),
    );
  }

  List<Widget> getUserItems(AsyncSnapshot<QuerySnapshot<Object?>> snapshot) {
    return snapshot.data!.docs.map(
      (doc) {
        if (nameKey == doc.get("full_name")) {
          return TextButton(
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) {
                  nameKey = "";
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
                    child: Text(doc["full_name"].toString()[0]),
                  ),
                ),
                title: Text(doc["full_name"]),
                subtitle: Text(doc["id"]),
              ),
            ),
          );
        }
        return new Text("");
      },
    ).toList();
  }

  void searchClient(String text) {
    nameKey = text;
  }
}
