import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';

import '../Login/login.dart';

class ProfileDisplayScreen extends StatefulWidget {
  const ProfileDisplayScreen({super.key});

  @override
  State<ProfileDisplayScreen> createState() => _ProfileDisplayScreenState();
}

class _ProfileDisplayScreenState extends State<ProfileDisplayScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  String fullName = '';
  String profileIcon = '';
  String id = '';
  String faculty = '';
  String major = '';

  void initState() {
    super.initState();
    _getCurrentUserData();
  }

  Future<void> _getCurrentUserData() async {
    final currentUser = await auth.currentUser!;
    if (currentUser != Null) {
      final collectionReference = fireStore.collection('Profile');
      final documentReference = collectionReference.doc(currentUser.uid);
      final documentSnapshot = await documentReference.get();
      if (documentSnapshot.exists) {
        setState(() {
          fullName = documentSnapshot.get('full_name').toString();
          id = documentSnapshot.get('id').toString();
          faculty = documentSnapshot.get('faculty').toString();
          major = documentSnapshot.get('major').toString();
          profileIcon = fullName[0];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.only(top: 150.0),
          child: Center(
            child: SizedBox(
              child: CircleAvatar(
                backgroundColor: Color(0xff392AAB),
                foregroundColor: Color(0xffffffff),
                child: SizedBox(
                  child: FittedBox(
                    child: Text(profileIcon),
                  ),
                  width: 80,
                  height: 80,
                ),
              ),
              width: 150,
              height: 150,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                Text(fullName,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Color(0xff392AAB),
                    )),
                Text(
                  id,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 22,
                    color: Color(0xff695FB1),
                  ),
                ),
              ],
            ),
          ),
        ),
        Center(
            child: SizedBox(
                width: 350,
                height: 80,
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(children: [
                      Text(
                        "EMAIL",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          auth.currentUser!.email.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  decoration: BoxDecoration(
                    color: Color(0xffffffff),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ))),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Center(
              child: SizedBox(
            width: 350,
            height: 80,
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Column(
                  children: [
                    Text("Major",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        )),
                    Text(major,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        )),
                    Text(faculty,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                        ))
                  ],
                ),
              ),
              decoration: BoxDecoration(
                  color: Color(0xffffffff), borderRadius: BorderRadius.circular(40)),
            ),
          )),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: SizedBox(
            width: 174,
            height: 40,
            child: ElevatedButton(
              onPressed: () async {
                await auth.signOut().then(
                  (value) {
                    Navigator.pushReplacement((context), MaterialPageRoute(
                      builder: (context) {
                        return const LoginScreen();
                      },
                    ));
                  },
                );
              },
              child: Text("SIGN-OUT",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  )),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff392AAB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  )),
            ),
          ),
        ),
      ]),
      backgroundColor: Color(0xffFAF9F9),
    );
  }
}
