import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:todo_app/Custom/AddLabel.dart';
import 'package:todo_app/Page/AddNewNote.dart';
import 'package:todo_app/Page/HomePage.dart';
import 'package:todo_app/Page/PhonePageAuth.dart';
import 'package:todo_app/Page/ProfilePage.dart';
import 'package:todo_app/Page/RecycleBin.dart';
import 'package:todo_app/Page/SignInPage.dart';
import 'package:todo_app/Page/SignUpPage.dart';
import 'package:todo_app/Service/Auth_Service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget currentPage = SignUpPage();
  AuthClass authClass = AuthClass();

  @override
  void dispose() {
    // TODO: implement dispose

    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  void checkLogin() async {
    String? token = await authClass.getToken();
    if (token != null) {
      setState(() {
        currentPage = HomePage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SignUpPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
