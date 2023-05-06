import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:todo_app/Page/HomePage.dart';
import 'package:todo_app/Page/PhonePageAuth.dart';
import 'package:todo_app/Page/SignInPage.dart';
import 'package:todo_app/Service/Auth_Service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  var _controllerEmail = TextEditingController();
  var _controllerPassword = TextEditingController();
  var _controllerConfirmPassword = TextEditingController();
  var _controllerFirstName = TextEditingController();
  var _controllerLastName = TextEditingController();
  var _controllerPhoneNumber = TextEditingController();

  bool circular = false;
  AuthClass authClass = AuthClass();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
            child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                color: Color(0xFFDCBBAA),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Text(
                        'Sign Up',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      buttonItem("assets/google.svg", "Continue with Google",
                          30, "Google"),
                      SizedBox(
                        height: 15,
                      ),
                      buttonItem("assets/phone.svg", "Continue with Phone", 30,
                          "Phone"),
                      SizedBox(
                        height: 15,
                      ),
                      Text('Or',
                          style: TextStyle(fontSize: 17, color: Colors.black)),
                      SizedBox(
                        height: 15,
                      ),
                      textItem("First Name", _controllerFirstName, false,
                          TextInputType.text),
                      SizedBox(
                        height: 15,
                      ),
                      textItem("Last Name", _controllerLastName, false,
                          TextInputType.text),
                      SizedBox(
                        height: 15,
                      ),
                      textItem("Phone", _controllerPhoneNumber, false,
                          TextInputType.phone),
                      SizedBox(
                        height: 15,
                      ),
                      textItem(
                          "Email", _controllerEmail, false, TextInputType.text),
                      SizedBox(
                        height: 15,
                      ),
                      textItem("Password", _controllerPassword, true,
                          TextInputType.text),
                      SizedBox(
                        height: 15,
                      ),
                      textItem("Confirm Your Password",
                          _controllerConfirmPassword, true, TextInputType.text),
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
                            "If you already have an account ?",
                            style: TextStyle(color: Colors.black, fontSize: 18),
                          ),
                          SizedBox(
                            width: 3,
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
                                    color: Colors.black,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold)),
                          )
                        ],
                      )
                    ],
                  ),
                ))));
  }

  addUserDetails(String firstName, String lastName, String email,
      String phoneNumber, String userID) async {
    await FirebaseFirestore.instance.collection('users').add({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'sizeText': '',
      'font':'',
      'soundNotification': '',
      'labels': [],
      'userID': userID
    });
  }

  Widget colorButton() {
    return InkWell(
      onTap: () async {
        setState(() {
          circular = true;
        });
        try {
          if (_controllerPassword.text == _controllerConfirmPassword.text) {
            firebase_auth.UserCredential userCredential =
                await firebaseAuth.createUserWithEmailAndPassword(
                    email: _controllerEmail.text,
                    password: _controllerPassword.text);
            print(userCredential.user);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Register account successfully')));
            setState(() {
              circular = false;
              _controllerPassword.text = "";
              _controllerConfirmPassword.text = "";
            });
            String userID = userCredential.user!.uid;
            addUserDetails(
                _controllerFirstName.text.trim(),
                _controllerLastName.text.trim(),
                _controllerEmail.text.trim(),
                _controllerPhoneNumber.text.trim(),
                userID);

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => SignInPage()),
                (route) => false);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('Confirm Password is wrong. Please check!')));
            setState(() {
              circular = false;
            });
          }
        } catch (e) {
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                : Text('Sign Up',
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
          style: TextStyle(fontSize: 17, color: Colors.black),
          controller: controller,
          obscureText: obscureText,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email or phone number';
            } else
              return null;
          },
          decoration: InputDecoration(
              labelText: name,
              labelStyle: TextStyle(fontSize: 17, color: Colors.black),
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
