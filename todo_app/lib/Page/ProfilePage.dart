import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:todo_app/Custom/AddLabel.dart';
import 'package:todo_app/Page/HomePage.dart';

import '../Service/Auth_Service.dart';
import 'SignUpPage.dart';
import 'package:todo_app/Custom/image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  final bool skipped;
  const ProfilePage({Key? key, this.skipped = false}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late QuerySnapshot _snapshotData;
  final ImagePicker _picker = ImagePicker();
  String? userName = FirebaseAuth.instance.currentUser?.displayName;
  AuthClass authClass = AuthClass();
  String? email = FirebaseAuth.instance.currentUser?.email;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController _numberController = TextEditingController();
  var userID = FirebaseAuth.instance.currentUser?.uid;

  XFile? image;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Text("Profile",
              style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
        ),
        body: SafeArea(
            child: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 20,
                ),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: getImage(),
                ),
                SizedBox(
                  height: 10,
                ),
                Column(
                  children: [
                    Text(
                      userName == null ? 'UserName' : userName.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      email == null ? 'Email' : email.toString(),
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    button("Save image"),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.add_a_photo,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.black,
                  thickness: 2,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      InkWell(
                        onTap: () {
                          _changePassword(context);
                        },
                        child: ListTile(
                          title: Text('Change your password',
                              style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          trailing: Icon(Icons.lock),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => AddLabel()));
                        },
                        child: ListTile(
                          title: Text('Manage your label',
                              style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          trailing: Icon(Icons.label),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      InkWell(
                        onTap: () {
                          _showNumberInputDialog(context);
                        },
                        child: ListTile(
                          title: Text('Change your size text',
                              style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          trailing: Icon(Icons.text_snippet),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      InkWell(
                        onTap: () {
                          _showFontWeightInputDialog(context);
                        },
                        child: ListTile(
                          title: Text('Change your font text',
                              style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          trailing: Icon(Icons.font_download),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      InkWell(
                        onTap: () {
                          _showSoundSelectionDialog(context);
                        },
                        child: ListTile(
                          title: Text('Change your sound notifications',
                              style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          trailing: Icon(Icons.volume_down),
                        ),
                      ),
                      Divider(
                        color: Colors.black,
                        thickness: 1,
                      ),
                      InkWell(
                        onTap: () async {
                          await authClass.logOut();
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => SignUpPage()));
                        },
                        child: ListTile(
                          title: Text('Log out',
                              style: GoogleFonts.lato(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black)),
                          trailing: Icon(Icons.logout),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )));
  }

  ImageProvider getImage() {
    if (image != null) {
      return FileImage(File(image!.path));
    }
    return AssetImage('assets/avatar.jpg');
  }

  Widget button(String name) {
    return InkWell(
      onTap: () {},
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width / 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(colors: [
            Color(0xff8a32f1),
            Color(0xffad32f9),
          ]),
        ),
        child: Center(
            child: Text(
          name,
          style: const TextStyle(color: Colors.white),
        )),
      ),
    );
  }

  void _changePassword(BuildContext context) {
    String? _password;
    String? _newPassword;
    String? _confirmPassword;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String errorMessage = "";
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Change Password"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Enter Current Password",
                      labelStyle: TextStyle(
                          fontSize: 15, color: Color.fromARGB(255, 33, 31, 31)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              width: 1.5,
                              color: Color.fromARGB(255, 241, 159, 108))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(width: 1, color: Colors.grey)),
                      hintText: "Enter current password",
                    ),
                    onChanged: (value) {
                      setState(() {
                        _password = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Enter New Password",
                      labelStyle: TextStyle(
                          fontSize: 15, color: Color.fromARGB(255, 33, 31, 31)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              width: 1.5,
                              color: Color.fromARGB(255, 241, 159, 108))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(width: 1, color: Colors.grey)),
                      hintText: "Enter new password",
                    ),
                    onChanged: (value) {
                      setState(() {
                        _newPassword = value;
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: "Confirm Password",
                      labelStyle: TextStyle(
                          fontSize: 15, color: Color.fromARGB(255, 33, 31, 31)),
                      focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                              width: 1.5,
                              color: Color.fromARGB(255, 241, 159, 108))),
                      enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(width: 1, color: Colors.grey)),
                      hintText: "Confirm Password",
                    ),
                    onChanged: (value) {
                      setState(() {
                        _confirmPassword = value;
                      });
                    },
                  ),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    if (_password == null || _password!.isEmpty) {
                      setState(() {
                        errorMessage = "Please enter current password";
                      });
                      return;
                    }
                    if (_newPassword == null || _newPassword!.isEmpty) {
                      setState(() {
                        errorMessage = "Please enter new password";
                      });
                      return;
                    }

                    if (_confirmPassword == null || _confirmPassword!.isEmpty) {
                      setState(() {
                        errorMessage = "Please enter confirm password";
                      });
                      return;
                    }
                    try {
                      User? user = _auth.currentUser;
                      if (user != null) {
                        if (_newPassword == _confirmPassword) {
                          AuthCredential credential =
                              EmailAuthProvider.credential(
                                  email: user.email!, password: _password!);
                          await user.reauthenticateWithCredential(credential);
                          await user.updatePassword(_newPassword!);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Password updated"),
                            ),
                          );
                        } else {
                          setState(() {
                            errorMessage =
                                "Please check your new and confirm password!";
                          });
                        }
                      }
                    } on FirebaseAuthException catch (e) {
                      setState(() {
                        errorMessage = "Error: " + e.message!;
                      });
                    }
                  },
                  child: Text("Change"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showNumberInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enter number size text from 10 to 30'),
        content: TextField(
          controller: _numberController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Size text from 10 to 30',
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              int? number = int.tryParse(_numberController.text);

              if (number != null && number >= 10 && number <= 30) {
                // Do something with the number
                print("userID: $userID");
                // print("userRef: ${userRef}");
                FirebaseFirestore.instance
                    .collection('users')
                    .where('userID', isEqualTo: userID)
                    .get()
                    .then((querySnapshot) {
                  querySnapshot.docs.forEach((doc) {
                    // Update the sizeText field of the document
                    doc.reference.update({'sizeText': _numberController.text});
                  });
                });

                print('Bạn đã nhập số $number');

                Navigator.of(context).pop();
              } else {
                // Show an error message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Enter number from 10 to 30'),
                  duration: Duration(seconds: 2),
                ));
              }
            },
          ),
        ],
      ),
    );
  }

  void _showSoundSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose a sound'),
        content: SingleChildScrollView(
          child: ListBody(
            children: [
              ListTile(
                title: Text('Sound 1'),
                onTap: () => _updateUserSound('sound_1'),
              ),
              ListTile(
                title: Text('Sound 2'),
                onTap: () => _updateUserSound('sound_2'),
              ),
              ListTile(
                title: Text('Sound 3'),
                onTap: () => _updateUserSound('sound_3'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateUserSound(String soundName) async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .where('userID', isEqualTo: userID);

    final userQuerySnapshot = await userRef.get();
    if (userQuerySnapshot.docs.length > 0) {
      final userDoc = userQuerySnapshot.docs[0];
      final String soundPath = soundName;
      userDoc.reference.update({'soundNotification': soundPath});
    }
  }

  void _showFontWeightInputDialog(BuildContext context) {
    FontWeight selectedFontWeight = FontWeight.normal;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose font weight'),
        content: DropdownButtonFormField<FontWeight>(
          value: selectedFontWeight,
          items: [
            DropdownMenuItem(
              value: FontWeight.normal,
              child: Text('Normal'),
            ),
            DropdownMenuItem(
              value: FontWeight.bold,
              child: Text('Bold'),
            ),
            DropdownMenuItem(
              value: FontWeight.w300,
              child: Text('Light'),
            ),
          ],
          onChanged: (value) {
            selectedFontWeight = value!;
          },
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              print("userID: $userID");
              FirebaseFirestore.instance
                  .collection('users')
                  .where('userID', isEqualTo: userID)
                  .get()
                  .then((querySnapshot) {
                querySnapshot.docs.forEach((doc) {
                  doc.reference.update({'font': selectedFontWeight.toString()});
                });
              });

              print(
                  'You have selected font weight ${selectedFontWeight.toString()}');

              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  getUserData() async {
    var userID = FirebaseAuth.instance.currentUser?.uid;
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection("NoteTask")
        .where("userID", isEqualTo: userID)
        .get();
    setState(() {
      _snapshotData = result;
    });
  }
}
