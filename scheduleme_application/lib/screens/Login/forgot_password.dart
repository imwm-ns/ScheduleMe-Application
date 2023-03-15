import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import 'package:scheduleme_application/models/account.dart';
import 'package:scheduleme_application/screens/Login/login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreen();
}

class _ForgotPasswordScreen extends State<ForgotPasswordScreen> {
  final formKey = GlobalKey<FormState>();
  Account account = Account(email: '', password: '');
  final FirebaseAuth auth = FirebaseAuth.instance;
  final Future<FirebaseApp> firebase = Firebase.initializeApp();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

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
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: 600,
        decoration: const BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(40),
            bottomRight: Radius.circular(40),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return const LoginScreen();
                          },
                        ));
                      },
                      icon: Icon(Icons.arrow_back),
                      color: Color(0xff392AAB),
                      iconSize: 30,
                    )),
                Container(
                  padding: const EdgeInsets.all(30),
                  child: Text(
                    "Forgot Password",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 24,
                      color: Color(0xff392AAB),
                    ),
                  ),
                ),
              ]),
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("EMAIL",
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    TextFormField(
                      autofocus: true,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(icon: Icon(Icons.account_circle)),
                      validator: MultiValidator([
                        RequiredValidator(errorText: "PLEASE ENTER YOUR EMAIL."),
                        EmailValidator(errorText: "THE TYPE OF EMAIL IS INVALID")
                      ]),
                      // decoration: const InputDecoration(border: ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("NEW PASSWORD",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
                        decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: isObscureTextPassword
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  isObscureTextPassword = !isObscureTextPassword;
                                });
                              },
                            )),
                        onSaved: (String? password) {
                          account.password = password!;
                        }
                        // decoration: const InputDecoration(border: ),
                        ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text("CONFIRM NEW PASSWORD",
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
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
                        decoration: InputDecoration(
                            icon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: isObscureTextPassword
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                              onPressed: () {
                                setState(() {
                                  isObscureTextPassword = !isObscureTextPassword;
                                });
                              },
                            )),
                        onSaved: (String? password) {
                          account.password = password!;
                        }
                        // decoration: const InputDecoration(border: ),
                        ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 50,
                  child: ElevatedButton(
                    child: Text(
                      "Reset Password",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff392AAB),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40))),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Color(0xff392AAB),
    );
  }
}
