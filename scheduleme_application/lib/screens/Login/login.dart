import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:scheduleme_application/models/account.dart';
import 'package:scheduleme_application/screens/Login/create_profile.dart';
import 'package:scheduleme_application/screens/Login/register.dart';
import 'package:scheduleme_application/screens/Widgets/mainbuttom.dart';
import 'package:scheduleme_application/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  Account account = Account(email: '', password: '');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  var isObscureText;
  var uidInSaved;

  @override
  void initState() {
    super.initState();
    isObscureText = true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: firebase,
        builder: ((context, snapshot) {
          if (snapshot.hasError) {
            return const Scaffold(
                body: Center(
              child: Text("Error."),
            ));
          }
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              resizeToAvoidBottomInset: false,
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 600,
                      decoration: const BoxDecoration(
                          color: Color(0xffffffff),
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(40),
                              bottomRight: Radius.circular(40))),
                      child: SingleChildScrollView(
                        child: Column(children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 100.0),
                            child: Container(
                              child: const Text("LOGIN",
                                  style: TextStyle(
                                      fontSize: 34, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          Form(
                            key: formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(50.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text("EMAIL",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 16)),
                                  TextFormField(
                                    autofocus: true,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: const InputDecoration(
                                        icon: Icon(Icons.account_circle)),
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: "PLEASE ENTER YOUR EMAIL."),
                                      EmailValidator(
                                          errorText: "THE TYPE OF EMAIL IS INVALID")
                                    ]),
                                    onSaved: (String? email) {
                                      account.email = email!;
                                    },
                                    // decoration: const InputDecoration(border: ),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  const Text("PASSWORD",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w700, fontSize: 16)),
                                  TextFormField(
                                      autofocus: true,
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return "PASSWORD IS REQUIRED PLEASE ENTER.";
                                        }
                                        if (value!.length < 6) {
                                          return "PASSWORD MUST BE AT LEAST 6 CHARACTERS.";
                                        }
                                        return null;
                                      },
                                      obscureText: isObscureText, // blind password.
                                      decoration: InputDecoration(
                                          icon: const Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                            padding: const EdgeInsetsDirectional.only(
                                                end: 12.0),
                                            icon: isObscureText
                                                ? const Icon(Icons.visibility)
                                                : const Icon(Icons.visibility_off),
                                            onPressed: () {
                                              setState(() {
                                                isObscureText = !isObscureText;
                                              });
                                            },
                                          )),
                                      onSaved: (String? password) {
                                        account.password = password!;
                                      }

                                      // decoration: const InputDecoration(border: ),
                                      ),
                                  Container(
                                    margin: const EdgeInsets.only(left: 180),
                                    child: SizedBox(
                                        child: TextButton(
                                      onPressed: () {},
                                      style: TextButton.styleFrom(
                                          foregroundColor: const Color(0xff392AAB)),
                                      child: const Text(
                                        "Forgot Password?",
                                        style: TextStyle(
                                            fontSize: 14, fontWeight: FontWeight.w500),
                                      ),
                                    )),
                                  ),
                                  Center(
                                    child: SizedBox(
                                        width: 145,
                                        height: 40,
                                        child: ElevatedButton(
                                          onPressed: () async {
                                            if (await formKey.currentState!.validate()) {
                                              formKey.currentState!.save();
                                              final documentReference = await firestore
                                                  .collection('Profile')
                                                  .doc(auth.currentUser?.uid);
                                              final documentSnapshot =
                                                  await documentReference.get();
                                              try {
                                                await auth
                                                    .signInWithEmailAndPassword(
                                                        email: account.email,
                                                        password: account.password)
                                                    .then(((value) async {
                                                  formKey.currentState!.reset();

                                                  final documentReference =
                                                      await firestore
                                                          .collection('Profile')
                                                          .doc(auth.currentUser?.uid);
                                                  final documentSnapshot =
                                                      await documentReference.get();

                                                  if (documentSnapshot.exists) {
                                                    setState(() {
                                                      final uidInSaved = documentSnapshot
                                                          .get('uid')
                                                          .toString();
                                                      if (auth.currentUser!.uid ==
                                                          uidInSaved) {
                                                        Fluttertoast.showToast(
                                                            msg: "Success",
                                                            gravity: ToastGravity.CENTER);
                                                        Navigator.pushReplacement(context,
                                                            MaterialPageRoute(
                                                                builder: (context) {
                                                          return const MainBottom();
                                                        }));
                                                      }
                                                    });
                                                  } else {
                                                    Navigator.pushReplacement(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return CreateProfileScreen();
                                                    }));
                                                  }
                                                }));
                                              } on FirebaseAuthException catch (e) {
                                                Fluttertoast.showToast(
                                                    msg: "${e.message}",
                                                    gravity: ToastGravity.CENTER);
                                              }
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xff392AAB),
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(40))),
                                          child: const Text("LOGIN",
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600)),
                                        )),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.all(30.0),
                                    child: Center(
                                      child: Text("OR",
                                          style: TextStyle(color: Color(0xff392AAB))),
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsetsDirectional.only(start: 50),
                                    child: Row(
                                      children: [
                                        Image.asset("assets/icon/google_logo.png"),
                                        TextButton(
                                            onPressed: () async {
                                              try {
                                                if (await AuthService().handleSignIn() !=
                                                    Null) {
                                                  Fluttertoast.showToast(
                                                      msg: "Success",
                                                      gravity: ToastGravity.CENTER);
                                                  final documentReference = firestore
                                                      .collection('Profile')
                                                      .doc(FirebaseAuth
                                                          .instance.currentUser!.uid);
                                                  final documentSnapshot =
                                                      await documentReference.get();
                                                  if (documentSnapshot.exists) {
                                                    final uidInSaved = documentSnapshot
                                                        .get('uid')
                                                        .toString();
                                                    if (FirebaseAuth
                                                            .instance.currentUser!.uid ==
                                                        uidInSaved) {
                                                      Navigator.pushReplacement(context,
                                                          MaterialPageRoute(
                                                              builder: (context) {
                                                        return const MainBottom();
                                                      }));
                                                    }
                                                  } else {
                                                    Navigator.pushReplacement(context,
                                                        MaterialPageRoute(
                                                            builder: (context) {
                                                      return CreateProfileScreen();
                                                    }));
                                                  }
                                                }
                                              } on FirebaseAuthException catch (e) {
                                                Fluttertoast.showToast(
                                                    msg: "${e.message}",
                                                    gravity: ToastGravity.CENTER);
                                              } on PlatformException catch (e) {
                                                Fluttertoast.showToast(
                                                    msg: "${e.code}",
                                                    gravity: ToastGravity.CENTER);
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                                foregroundColor:
                                                    Color.fromARGB(255, 0, 0, 0)),
                                            child: Text("Sign-in with google",
                                                style: TextStyle(fontSize: 18)))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ]),
                      ),
                    ),
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: SizedBox(
                            width: 174,
                            height: 40,
                            child: Container(
                                child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const RegisterScreen();
                                }));
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xffffffff),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40))),
                              child: const Text(
                                "SIGN-IN",
                                style: TextStyle(
                                    color: Color(0xff392AAB),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                              ),
                            ))),
                      ),
                    )
                  ],
                ),
              ),
              backgroundColor: Color(0xff392AAB),
            );
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }));
  }
}
