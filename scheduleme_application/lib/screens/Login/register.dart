import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:form_field_validator/form_field_validator.dart';
import 'package:scheduleme_application/models/account.dart';
import 'package:scheduleme_application/screens/Login/login.dart';
import 'package:scheduleme_application/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();
  Account account = Account(email: '', password: '');
  final Future<FirebaseApp> firebase = Firebase.initializeApp();
  final AuthService authService = AuthService();

  String password = '';
  String confirmPassword = '';

  var isConfirm;
  var isObscureTextPassword;
  var isObscureTextConfirm;

  @override
  void initState() {
    super.initState();

    isConfirm = false;
    isObscureTextPassword = true;
    isObscureTextConfirm = true;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(body: Center(child: Text("Error.")));
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            body: SingleChildScrollView(
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
                  Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Text("Welcome!",
                          style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w600,
                              color: Color(0xffffffff))),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 100),
                    child: Container(
                      width: double.infinity,
                      height: 680,
                      decoration: const BoxDecoration(
                          color: Color(0xffffffff),
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(40),
                              topRight: Radius.circular(40))),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(50.0),
                            child: Container(
                              alignment: Alignment.center,
                              child: const Text("SIGN-IN",
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  )),
                            ),
                          ),
                          Form(
                            key: formKey,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50, right: 50),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("EMAIL",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w600, fontSize: 16)),
                                  TextFormField(
                                    decoration: const InputDecoration(
                                        icon: Icon(Icons.account_circle)),
                                    autofocus: true,
                                    keyboardType: TextInputType.emailAddress,
                                    onSaved: (String? email) {
                                      account.email = email!;
                                    },
                                    validator: MultiValidator([
                                      RequiredValidator(
                                          errorText: "EMAIL IS REQUIRED PLEASE ENTER."),
                                      EmailValidator(
                                          errorText: "THE TYPE OF EMAIL IS INVALID.")
                                    ]),
                                  ),
                                  const SizedBox(height: 15),
                                  const Text("PASSWORD",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.w600)),
                                  TextFormField(
                                      decoration: InputDecoration(
                                          icon: const Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                            icon: isObscureTextPassword
                                                ? const Icon(Icons.visibility)
                                                : const Icon(Icons.visibility_off),
                                            onPressed: () {
                                              setState(() {
                                                isObscureTextPassword =
                                                    !isObscureTextPassword;
                                              });
                                            },
                                          )),
                                      autofocus: true,
                                      onChanged: (value) {
                                        password = value;
                                      },
                                      obscureText: isObscureTextPassword,
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return "PASSWORD IS REQUIRED PLEASE ENTER";
                                        }
                                        if (value!.length < 6) {
                                          return "PASSWORD MUST BE AT LEAST 6 CHARACTERS.";
                                        }
                                        return null;
                                      }),
                                  const SizedBox(height: 15),
                                  const Text("CONFIRM PASSWORD",
                                      style: TextStyle(
                                          fontSize: 16, fontWeight: FontWeight.w600)),
                                  TextFormField(
                                      decoration: InputDecoration(
                                          icon: const Icon(Icons.lock),
                                          suffixIcon: IconButton(
                                              icon: isObscureTextConfirm
                                                  ? const Icon(Icons.visibility)
                                                  : const Icon(Icons.visibility_off),
                                              onPressed: () {
                                                setState(
                                                  () {
                                                    isObscureTextConfirm =
                                                        !isObscureTextConfirm;
                                                  },
                                                );
                                              })),
                                      autofocus: true,
                                      onChanged: (value) {
                                        confirmPassword = value;
                                      },
                                      obscureText: isObscureTextConfirm,
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return "CONFIRM PASSWORD IS REQUIRED PLEASE ENTER";
                                        }
                                        if (value != password) {
                                          return "CONFIRM PASSWORD NOT MATCHING.";
                                        }
                                        if (value!.length < 6) {
                                          return "PASSWORD MUST BE AT LEAST 6 CHARACTERS.";
                                        }
                                        return null;
                                      }),
                                  const SizedBox(height: 15),
                                  Center(
                                    child: SizedBox(
                                      width: 153,
                                      height: 40,
                                      child: ElevatedButton(
                                        onPressed: () async {
                                          if (formKey.currentState!.validate()) {
                                            account.password = password;
                                            formKey.currentState!.save();
                                            try {
                                              await FirebaseAuth.instance
                                                  .createUserWithEmailAndPassword(
                                                      email: account.email,
                                                      password: account.password)
                                                  .then((value) {
                                                Fluttertoast.showToast(
                                                    msg: "Success",
                                                    gravity: ToastGravity.CENTER);
                                                formKey.currentState!.reset();
                                                Navigator.pushReplacement(context,
                                                    MaterialPageRoute(builder: (context) {
                                                  return const LoginScreen();
                                                }));
                                              });
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
                                                borderRadius: BorderRadius.circular(40))),
                                        child: const Text("SIGN-IN",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            backgroundColor: const Color(0xff392AAB),
          );
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
