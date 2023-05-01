import 'dart:async';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:flutter/material.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';
import 'package:todo_app/Page/HomePage.dart';
// import 'package:libphonenumber/libphonenumber.dart';

import '../Service/Auth_Service.dart';

class PhonePageAuth extends StatefulWidget {
  const PhonePageAuth({super.key});

  @override
  State<PhonePageAuth> createState() => _PhonePageAuthState();
}

class _PhonePageAuthState extends State<PhonePageAuth> {
  int start = 59;
  bool wait = false;
  String buttonName = "Send";
  TextEditingController phoneController = TextEditingController();
  AuthClass authClass = AuthClass();
  String verificationIDFinal = "";
  String smsCode = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text("Sign Up",
              style: TextStyle(color: Colors.white, fontSize: 24)),
          centerTitle: true,
        ),
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(
                  height: 150,
                ),
                TextFeild(),
                SizedBox(
                  height: 20,
                ),
                Container(
                    width: MediaQuery.of(context).size.width - 30,
                    child: Row(
                      children: [
                        Expanded(
                            child: Container(
                          height: 1,
                          color: Colors.grey,
                          margin: EdgeInsets.symmetric(horizontal: 12),
                        )),
                        Text('Enter 6 digit OTP',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                        Expanded(
                            child: Container(
                          height: 1,
                          color: Colors.grey,
                          margin: EdgeInsets.symmetric(horizontal: 12),
                        )),
                      ],
                    )),
                SizedBox(
                  height: 35,
                ),
                OTPFeild(),
                SizedBox(
                  height: 40,
                ),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: "Send OTP again in ",
                      style: TextStyle(fontSize: 16, color: Colors.amber)),
                  TextSpan(
                      text: "00:$start ",
                      style: TextStyle(fontSize: 16, color: Colors.red)),
                  TextSpan(
                      text: "sec",
                      style: TextStyle(fontSize: 16, color: Colors.amber))
                ])),
                SizedBox(
                  height: 100,
                ),
                InkWell(
                  onTap: () {
                    authClass.SignInWithPhoneNumber(
                        verificationIDFinal, smsCode, context);
                  },
                  child: Container(
                      height: 60,
                      width: MediaQuery.of(context).size.width - 60,
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 212, 101, 36),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                          child: Text('Lets go',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)))),
                ),
                SizedBox(
                  height: 15,
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (builder) => HomePage()));
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
                                "assets/next.svg",
                                height: 30,
                                width: 30,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text("Skip and enter later",
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.white))
                            ],
                          ))),
                ),
              ],
            ))));
  }

  void StartTimer() {
    const onsec = Duration(seconds: 1);
    Timer timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
          wait = false;
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  Widget OTPFeild() {
    return OTPTextField(
        // controller: otpController,
        length: 6, // updated to 6
        width: MediaQuery.of(context).size.width - 34,
        fieldWidth: 58,
        otpFieldStyle: OtpFieldStyle(
            backgroundColor: Color(0xff1d1d1d), borderColor: Colors.white),
        style: TextStyle(fontSize: 17, color: Colors.white),
        textFieldAlignment: MainAxisAlignment.spaceAround,
        fieldStyle: FieldStyle.underline,
        onChanged: (String? pin) {
          print("Changed: " + pin!);
          setState(() {
            smsCode = pin;
          });
        },
        onCompleted: (String? pin) {
          print("Completed: " + pin!);
        });
  }

  Widget TextFeild() {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 60,
      decoration: BoxDecoration(
          color: Color(0xff1d1d1d), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        keyboardType: TextInputType.phone,
        style: TextStyle(color: Colors.white),
        controller: phoneController,
        decoration: InputDecoration(
            border: InputBorder.none,
            labelStyle: TextStyle(color: Colors.white, fontSize: 17),
            hintText: "Enter your phone number",
            hintStyle: TextStyle(color: Colors.white54, fontSize: 17),
            contentPadding: EdgeInsets.symmetric(vertical: 19, horizontal: 8),
            prefixIcon: Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
              child: Text(
                ' (+84) ',
                style: TextStyle(color: Colors.white, fontSize: 17),
              ),
            ),
            suffixIcon: InkWell(
              onTap: wait
                  ? null
                  : () async {
                      StartTimer();
                      setState(() {
                        start = 59;
                        wait = true;
                        buttonName = "Re-send";
                      });
                      await authClass.verifyPhoneNumber(
                          "+84 ${phoneController.text}", context, setData);
                    },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                child: Text(
                  buttonName,
                  style: TextStyle(
                      color: wait ? Colors.grey : Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold),
                ),
              ),
            )),
      ),
    );
  }

  void setData(verificationID) {
    setState(() {
      verificationIDFinal = verificationID;
    });
    StartTimer();
  }
}
