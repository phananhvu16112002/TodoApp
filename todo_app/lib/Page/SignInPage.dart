import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo_app/Page/PhonePageAuth.dart';
import 'package:todo_app/Page/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../Service/Auth_Service.dart';
import 'HomePage.dart';
import 'ForgotPasswordPage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  var _controllerEmail = TextEditingController();
  var _controllerPassword = TextEditingController();
  bool circular = false;
  AuthClass authClass = AuthClass();
  var userID;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sign In',
                      style: TextStyle(
                          fontSize: 35,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    buttonItem("assets/google.svg", "Continue with Google", 30,
                        "Google"),
                    SizedBox(
                      height: 15,
                    ),
                    buttonItem(
                        "assets/phone.svg", "Continue with Phone", 30, "Phone"),
                    SizedBox(
                      height: 15,
                    ),
                    Text('Or',
                        style: TextStyle(fontSize: 17, color: Colors.white)),
                    SizedBox(
                      height: 15,
                    ),
                    textItem("Email", _controllerEmail, false,
                        TextInputType.emailAddress),
                    SizedBox(
                      height: 15,
                    ),
                    textItem("Password", _controllerPassword, true,
                        TextInputType.text),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    colorButton(),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "If you don't have an account ?",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        InkWell(
                            onTap: () {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (builder) => SignUpPage()),
                                  (route) => false);
                            },
                            child: Text("Register",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)))
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => ForgotPasswordPage()),
                            (route) => false);
                      },
                      child: Text("Forgot password ?",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    )
                  ],
                ))));
  }

  Widget colorButton() {
    return InkWell(
      onTap: () async {
        try {
          firebase_auth.UserCredential userCredential =
              await firebaseAuth.signInWithEmailAndPassword(
                  email: _controllerEmail.text,
                  password: _controllerPassword.text);


          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text('Sign In Successfully')));
          setState(() {
            circular = false;
          });
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (builder) => HomePage()),
              (route) => false);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Password is wrong. Please check!')));
          setState(() {
            circular = false;
          });
        }
      },
      child: Container(
          width: MediaQuery.of(context).size.width - 90,
          height: 60,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [
                Color.fromARGB(255, 214, 71, 19),
                Color.fromARGB(255, 240, 166, 129),
                Color.fromARGB(255, 214, 71, 19)
              ])),
          child: Center(
            child: circular
                ? CircularProgressIndicator()
                : Text('Sign In',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
          )),
    );
  }

  Widget buttonItem(
      String imagePath, String buttonName, double size, String type) {
    return InkWell(
      onTap: () async {
        if (type == "Google") {
          await authClass.googleSignIn(context);
        } else if (type == "Phone") {
          Navigator.push(context,
              MaterialPageRoute(builder: (builder) => PhonePageAuth()));
        } else {}
      },
      child: Container(
          width: MediaQuery.of(context).size.width - 60,
          height: 60,
          child: Card(
              color: Colors.black,
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(width: 1, color: Colors.grey)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    imagePath,
                    height: size,
                    width: size,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text(buttonName,
                      style: TextStyle(fontSize: 17, color: Colors.white))
                ],
              ))),
    );
  }

  Widget textItem(String name, TextEditingController controller,
      bool obscureText, TextInputType inputType) {
    return Container(
        width: MediaQuery.of(context).size.width - 70,
        height: 60,
        child: TextFormField(
          keyboardType: inputType,
          style: TextStyle(fontSize: 17, color: Colors.white),
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
              labelText: name,
              labelStyle: TextStyle(fontSize: 17, color: Colors.white),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(
                      width: 1.5, color: Color.fromARGB(255, 241, 159, 108))),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(width: 1, color: Colors.grey))),
        ));
  }
}
