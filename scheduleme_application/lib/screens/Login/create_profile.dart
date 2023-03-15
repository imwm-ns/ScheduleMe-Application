import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:scheduleme_application/models/profile.dart';
import 'package:scheduleme_application/screens/Login/login.dart';
import 'package:scheduleme_application/screens/Widgets/mainbuttom.dart';

class CreateProfileScreen extends StatefulWidget {
  const CreateProfileScreen({super.key});

  @override
  State<CreateProfileScreen> createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  Profile profile = Profile(fullName: '', id: '', faculty: '', major: '', chatID: '');

  final formKey = GlobalKey<FormState>();
  final FirebaseAuth auth = FirebaseAuth.instance;
  Future<FirebaseApp> firebase = Firebase.initializeApp();
  final CollectionReference _profileCollection =
      FirebaseFirestore.instance.collection("Profile");

  var addPicture;

  @override
  void initState() {
    super.initState();

    addPicture = false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(body: Center(child: Text("Error.")));
          }
          if (snapshot.hasData) {
            return Scaffold(
              body: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                            padding: const EdgeInsets.only(top: 50.0, left: 15),
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(context, MaterialPageRoute(
                                  builder: (context) {
                                    return const LoginScreen();
                                  },
                                ));
                              },
                              icon: Icon(Icons.arrow_back),
                              color: Color(0xffffffff),
                              iconSize: 30,
                            )),
                      ]),
                      Container(
                        margin: const EdgeInsetsDirectional.only(top: 50),
                        width: double.infinity,
                        height: 800,
                        decoration: BoxDecoration(
                            color: Color(0xffffffff),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40),
                            )),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 50),
                              child: SizedBox(
                                child: CircleAvatar(
                                    backgroundColor: Color(0xffBCC1CD),
                                    child: TextButton(
                                      onPressed: () {},
                                      child: Icon(
                                        Icons.add,
                                        size: 70,
                                        color: Color(0xffffffff),
                                      ),
                                    )),
                                width: 100,
                                height: 100,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 30),
                              child: Text("CREATE PROFILE",
                                  style: TextStyle(
                                      fontSize: 28, fontWeight: FontWeight.w800)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("FULL NAME",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  TextFormField(
                                    onSaved: (String? fullName) {
                                      profile.fullName = fullName!;
                                    },
                                    autofocus: true,
                                    validator: (value) {
                                      if (value != null && value.isEmpty) {
                                        return "FULL NAME IS REQUIRED. PLEASE ENTER.";
                                      }
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  Text("STUDENT ID/ STAFF ID",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  TextFormField(
                                    onSaved: (String? id) {
                                      profile.id = id!;
                                    },
                                    autofocus: true,
                                    keyboardType: TextInputType.number,
                                    validator: (value) {
                                      if (value != null && value.isEmpty) {
                                        return "STUDENT ID / STAFF ID IS REQUIRED. PLEASE ENTER.";
                                      }
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  Text("FACULTY",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  TextFormField(
                                    onSaved: (String? faculty) {
                                      profile.faculty = faculty!;
                                    },
                                    autofocus: true,
                                    validator: (value) {
                                      if (value != null && value.isEmpty) {
                                        return "FACULTY IS REQUIRED. PLEASE ENTER.";
                                      }
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  Text("MAJOR",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      )),
                                  TextFormField(
                                    onSaved: (String? major) {
                                      profile.major = major!;
                                    },
                                    autofocus: true,
                                    validator: (value) {
                                      if (value != null && value.isEmpty) {
                                        return "MAJOR IS REQUIRED. PLEASE ENTER.";
                                      }
                                    },
                                  ),
                                  SizedBox(height: 15),
                                  Center(
                                    child: SizedBox(
                                      width: 145,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (formKey.currentState!.validate()) {
                                            formKey.currentState!.save();
                                            await _profileCollection
                                                .doc(auth.currentUser!.uid)
                                                .set({
                                              "full_name": profile.fullName,
                                              "id": profile.id,
                                              "faculty": profile.faculty,
                                              "major": profile.major,
                                              "uid": auth.currentUser!.uid,
                                              "chatID": profile.id
                                                  .substring(profile.id.length - 5),
                                            });
                                            print(profile.id
                                                .substring(profile.id.length - 5));
                                            formKey.currentState!.reset();
                                            Navigator.pushReplacement(context,
                                                MaterialPageRoute(builder: (context) {
                                              return const MainBottom();
                                            }));
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xff392AAB),
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(40))),
                                        child: Text("CREATE",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            )),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              backgroundColor: Color(0xff392AAB),
            );
          }
          return Scaffold(
            body: CircularProgressIndicator(),
          );
        });
  }
}
