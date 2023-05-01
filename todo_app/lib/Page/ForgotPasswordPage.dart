import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:todo_app/Page/PhonePageAuth.dart';
import 'package:todo_app/Page/SignInPage.dart';
import 'package:todo_app/Page/SignUpPage.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../Service/Auth_Service.dart';
import 'HomePage.dart';
import 'package:phone_number/phone_number.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  late SignInPage _ancestorWidget;
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  var _controller = TextEditingController();
  var _controllerPhoneNumber = TextEditingController();
  bool circular = false;
  AuthClass authClass = AuthClass();
  final emailValidator = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final phoneValidator = RegExp(r'(^(?:[+0]9)?[0-9]{10,12}$)');
  var _key = GlobalKey<FormState>();

  @override
  void dispose() {
    // Now it's safe to access _ancestorWidget in dispose()
    super.dispose();
  }

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
                      'Forgot Password',
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
                    Text('Reset your password',
                        style: TextStyle(fontSize: 17, color: Colors.white)),
                    SizedBox(
                      height: 15,
                    ),
                    textItem("Email or Phone", _controller, false,
                        TextInputType.emailAddress),
                    SizedBox(
                      height: 15,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    // colorButton(),
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
                                builder: (builder) => SignInPage()),
                            (route) => false);
                      },
                      child: Text("Login",
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
      onTap: () {
        try {
          if (_key.currentState != null && _key.currentState!.validate()) {
            // do something
            if (emailValidator.hasMatch(_controller.text.trim())) {
              authClass.ResetPasswordWithEmail(_controller.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'Sent Link Reset Your Password in Email! Please check your email')));
            }
            if (validatePhoneNumber(_controller.text)) {
              authClass.resetPassword(_controller.text.trim());
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content:
                      Text('Please check your phone! OTP had been sent ')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please check your phone number!')));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Please enter a valid email or phone number')));
          }
          setState(() {
            circular = false;
            _controller.text = "";
          });
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Email is wrong. Please check!')));
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
                : Text('Reset your password',
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
    return Form(
      key: _key,
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width - 70,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email or phone number';
                  } else if (emailValidator.hasMatch(value)) {
                    return null; // valid email
                  } else if (phoneValidator.hasMatch(value)) {
                    return null; // valid phone number
                  } else {
                    return 'Invalid email or phone number';
                  }
                },
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
                            width: 1.5,
                            color: Color.fromARGB(255, 241, 159, 108))),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide(width: 1, color: Colors.grey))),
              ),
              SizedBox(
                height: 15,
              ),
              colorButton()
            ],
          ),
        ),
      ),
    );
  }

  bool validatePhoneNumber(String phone) {
    return phoneValidator.hasMatch(phone);
  }
}
