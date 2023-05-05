import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/Custom/GridCard.dart';
import 'package:todo_app/Custom/NoteCard.dart';
import 'package:todo_app/Page/AddNewNote.dart';
import 'package:todo_app/Page/HomePage.dart';
import 'package:todo_app/Page/PhonePageAuth.dart';
import 'package:todo_app/Page/RecycleBin.dart';
import 'package:todo_app/Page/SignInPage.dart';
import 'package:todo_app/Page/SignUpPage.dart';
import 'package:todo_app/Page/ViewNote.dart';
import 'package:todo_app/Service/Auth_Service.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_app/Service/notifications_service.dart';

class RecycleBin extends StatefulWidget {
  const RecycleBin({super.key});

  @override
  State<RecycleBin> createState() => _HomePageState();
}

class _HomePageState extends State<RecycleBin> {
  List<Select> selected = [];
  AuthClass authClass = AuthClass();
  late QuerySnapshot _snapshotData;
  bool checkListView = true;
  var _controllerTimeDelete = TextEditingController();
  String _timeDelete = DateFormat("hh:mm a").format(DateTime.now()).toString();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late List<Map<String, dynamic>> _noteList;
  late List<Map<String, dynamic>> _allNotes;
  DateTime _selectedDate = DateTime.now();
  DateTime dateChoose = DateTime.now();
  late var _noteStream;
  var notifyHelper = NotificationsService();

  @override
  void dispose() {
    // TODO: implement dispose
    PhonePageAuth();
    super.dispose();
  }

  @override
  void initState() {
    var userID = FirebaseAuth.instance.currentUser?.uid;
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection("NoteTask")
        .where("userID", isEqualTo: userID)
        .snapshots();
    _noteStream = _stream;
    _stream.listen((QuerySnapshot snapshot) {
      _allNotes =
          snapshot.docs.map((e) => e.data() as Map<String, dynamic>).toList();
      _noteList = _allNotes;
    });

    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    var userID = FirebaseAuth.instance.currentUser?.uid;
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    String? userName = FirebaseAuth.instance.currentUser?.displayName;
    String? userPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    TextEditingController _timeDeleteController = TextEditingController();

    bool completed = false;
    List<Map<String, dynamic>> pinnedNotes = [];
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection("NoteTask")
        .where("userID", isEqualTo: userID)
        .snapshots();

    return Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: Center(
            child: Text("Recycle Bin",
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ),
          bottom: PreferredSize(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(DateFormat.yMMMMd().format(DateTime.now()),
                            style: subHeadingStyle),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            onPressed: () {
                              //Should show Dialog yes no
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Delete Note ?"),
                                      content: Text(
                                          "Are you sure you want to delete this note ?"),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Cancel")),
                                        TextButton(
                                            onPressed: () {
                                              var instance = FirebaseFirestore
                                                  .instance
                                                  .collection("NoteTask");
                                              for (var i = 0;
                                                  i < selected.length;
                                                  i++) {
                                                if (selected[i].checkValue) {
                                                  instance
                                                      .doc(selected[i].id)
                                                      .delete();
                                                }
                                              }
                                            },
                                            child: Text('Delete'))
                                      ],
                                    );
                                  });
                            },
                            icon: Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 28,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            preferredSize: Size.fromHeight(35),
          ),
        ),
        drawer: Drawer(
            child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.black87,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Text(
                        userName == null ? "Username" : userName,
                        style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    userEmail == null ? "Email Address" : userEmail,
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                setState(() {
                  checkListView = !checkListView;
                });
              },
              child: ListTile(
                title: Text('Change Display(Grid/List View)',
                    style: TextStyle(fontSize: 16)),
                trailing: checkListView
                    ? Icon(Icons.view_array)
                    : Icon(Icons.grid_3x3_outlined),
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 3,
                color: Color.fromARGB(255, 209, 206, 206)),
            InkWell(
              onTap: () {
                _changePassword(context);
              },
              child: ListTile(
                title: Text('Change Your Password',
                    style: TextStyle(fontSize: 16)),
                trailing: Icon(Icons.password),
              ),
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 3,
                color: Color.fromARGB(255, 209, 206, 206)),
            ListTile(
              title: Text(
                'Home',
                style: TextStyle(fontSize: 16),
              ),
              trailing: Icon(Icons.home),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (builder) => HomePage()),
                    (route) => false);
              },
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 3,
                color: Color.fromARGB(255, 209, 206, 206)),
            ListTile(
              title: Text(
                'Sign Out',
                style: TextStyle(fontSize: 16),
              ),
              trailing: Icon(Icons.logout_outlined),
              onTap: () async {
                await authClass.logOut();
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (builder) => SignUpPage()));
              },
            ),
            Container(
                width: MediaQuery.of(context).size.width,
                height: 3,
                color: Color.fromARGB(255, 209, 206, 206)),
          ],
        )),
        bottomNavigationBar:
            BottomNavigationBar(backgroundColor: Colors.black87, items: [
          BottomNavigationBarItem(
            icon: InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (builder) => HomePage()),
                      (route) => false);
                },
                child: Icon(Icons.home, size: 32, color: Colors.white)),
            label: 'Home',
          ),
          BottomNavigationBarItem(
              icon: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [Colors.indigoAccent, Colors.purple])),
                  child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => AddNewNote()));
                      },
                      child: Icon(Icons.add, size: 32, color: Colors.white))),
              label: 'Add Note'),
          BottomNavigationBarItem(
              icon: InkWell(
                  onTap: () {},
                  child: Icon(Icons.settings, size: 32, color: Colors.white)),
              label: 'Settings'),
        ]),
        body: SafeArea(
          child: FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance
                .collection('NoteTask')
                .where("userID", isEqualTo: userID)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error'));
              }
              final docs = snapshot.data!.docs;
              var count = 0;
              for (int i = 0; i < docs.length; i++) {
                var temp =
                    snapshot.data!.docs[i].data() as Map<String, dynamic>;
                String id = snapshot.data!.docs[i].id;
                if (temp['isDeleted'] == true) {
                  count++;
                }
              }

              return Column(
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      child: Column(
                        children: [
                          _addDateBar(),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "All Delete",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "${count}",
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                        ],
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  count == 0
                      ? Container(
                          child: Center(
                              child: Opacity(
                                  opacity: 0.5,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset('assets/note.jpg',
                                          width: 150, height: 150),
                                      Text('No Notes Delete',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 24))
                                    ],
                                  ))),
                          height: 400,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black87,
                          ),
                        )
                      : Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream: _stream,
                            builder: (BuildContext context,
                                AsyncSnapshot<QuerySnapshot> snapshot) {
                              if (snapshot.hasError) {
                                return Center(
                                    child: Text('Error: ${snapshot.error}'));
                              }
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                    child: CircularProgressIndicator());
                              }
                              return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    IconData iconData;
                                    Color iconColor;
                                    Map<String, dynamic> document =
                                        snapshot.data!.docs[index].data()
                                            as Map<String, dynamic>;
                                    String id = snapshot.data!.docs[index].id;
                                    bool check = false;
                                    for (int i = 0;
                                        i < snapshot.data!.docs.length;
                                        i++) {
                                      var id = snapshot.data!.docs[i].id;
                                      var temp = snapshot.data!.docs[i].data()
                                          as Map<String, dynamic>;
                                      try {
                                        var minute = int.parse(
                                            temp['TimeDelete']
                                                .toString()
                                                .split(":")[1]
                                                .split(" ")[0]);
                                        var hour = int.parse(temp['TimeDelete']
                                            .toString()
                                            .split(":")[0]);
                                        if (TimeOfDay.now().hour == hour &&
                                            TimeOfDay.now().minute == minute) {
                                          FirebaseFirestore.instance
                                              .collection("NoteTask")
                                              .doc(id)
                                              .delete();
                                          setState(() {});
                                        }
                                      } catch (e) {
                                        print(e);
                                      }
                                    }
                                    switch (document['Category']) {
                                      case "Work":
                                        iconData = Icons.run_circle_outlined;
                                        iconColor = Colors.red;
                                        break;
                                      case "WorkOut":
                                        iconData = Icons.alarm;
                                        iconColor = Colors.teal;
                                        break;
                                      case "Food":
                                        iconData = Icons.food_bank;
                                        iconColor = Colors.green;
                                        break;
                                      case "Design":
                                        iconData =
                                            Icons.design_services_outlined;
                                        iconColor = Colors.teal;
                                        break;
                                      case "Run":
                                        iconData = Icons.sports_esports;
                                        iconColor =
                                            Color.fromARGB(255, 199, 228, 36);
                                        break;
                                      default:
                                        iconData = Icons.run_circle_outlined;
                                        iconColor = Colors.red;
                                    }
                                    selected.add(Select(
                                        snapshot.data!.docs[index].id, false));
                                    return GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      ViewNote(
                                                          document: document,
                                                          id: snapshot
                                                              .data!
                                                              .docs[index]
                                                              .id)));
                                        },
                                        child: Slidable(
                                          key: const ValueKey(0),
                                          endActionPane: ActionPane(
                                              motion: ScrollMotion(),
                                              children: [
                                                SlidableAction(
                                                  onPressed: (context) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                "Delete Note ?"),
                                                            content: Text(
                                                                "Are you sure you want to delete this note ?"),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      "Cancel")),
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    String id =
                                                                        snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                            .id;
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "NoteTask")
                                                                        .doc(id)
                                                                        .delete();
                                                                    Navigator.pushAndRemoveUntil(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (builder) =>
                                                                                RecycleBin()),
                                                                        (route) =>
                                                                            false);
                                                                  },
                                                                  child: Text(
                                                                      'Delete'))
                                                            ],
                                                          );
                                                        });
                                                  },
                                                  backgroundColor:
                                                      Color(0xFFFE4A49),
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.delete,
                                                  label: 'Delete',
                                                ),
                                                SlidableAction(
                                                  onPressed: (context) {
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            title: Text(
                                                                "Recycle Note ?"),
                                                            content: Text(
                                                                "Are you sure you want to recycle this note ?"),
                                                            actions: [
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.of(
                                                                            context)
                                                                        .pop();
                                                                  },
                                                                  child: Text(
                                                                      "Cancel")),
                                                              TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    String id =
                                                                        snapshot
                                                                            .data!
                                                                            .docs[index]
                                                                            .id;
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            "NoteTask")
                                                                        .doc(id)
                                                                        .update({
                                                                      'isDeleted':
                                                                          false
                                                                    });
                                                                    Navigator.pushAndRemoveUntil(
                                                                        context,
                                                                        MaterialPageRoute(
                                                                            builder: (builder) =>
                                                                                RecycleBin()),
                                                                        (route) =>
                                                                            false);
                                                                  },
                                                                  child: Text(
                                                                      'Recycle'))
                                                            ],
                                                          );
                                                        });
                                                  },
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 51, 180, 70),
                                                  foregroundColor: Colors.white,
                                                  icon:
                                                      Icons.recycling_outlined,
                                                  label: 'Recycle',
                                                ),
                                                SlidableAction(
                                                  onPressed: (context) async {
                                                    _showTimePicker(id);
                                                  },
                                                  backgroundColor:
                                                      Color.fromARGB(
                                                          255, 180, 126, 51),
                                                  foregroundColor: Colors.white,
                                                  icon: Icons.auto_delete,
                                                  label: 'Auto Delete',
                                                ),
                                              ]),
                                          child: document['isDeleted'] == true
                                              ? NoteCard(
                                                  title:
                                                      document['title'] == null
                                                          ? "Hey There"
                                                          : document['title'],
                                                  iconData: iconData,
                                                  colorIcon: iconColor,
                                                  timeStart:
                                                      document['TimeStart'],
                                                  check: selected[index]
                                                      .checkValue,
                                                  iconBGColor: Colors.white,
                                                  index: index,
                                                  onChanged: onChange,
                                                  completed:
                                                      document['Completed'],
                                                  timeFinish:
                                                      document['TimeFinish'],
                                                  dateFinish:
                                                      document['DateFinish'],
                                                  protected:
                                                      document['Protected'],
                                                  description:
                                                      document['decription'],
                                                  isDeleted:
                                                      document['isDeleted'],
                                                  timeDelete:
                                                      document['TimeDelete'],
                                                )
                                              : Container(),
                                        ));
                                  });
                            },
                          ),
                        )
                  // rest of the UI code
                ],
              );
            },
          ),
        ));
  }

  _addDateBar() {
    return StatefulBuilder(builder: (context, setState) {
      return Container(
        child: DatePicker(
          height: 100,
          width: 80,
          DateTime.now(),
          initialSelectedDate: DateTime.now(),
          selectionColor: Color.fromARGB(255, 156, 65, 179),
          selectedTextColor: Colors.white,
          dateTextStyle: GoogleFonts.lato(
              textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          )),
          monthTextStyle: GoogleFonts.lato(
              textStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          )),
          dayTextStyle: GoogleFonts.lato(
              textStyle: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
          )),
          onDateChange: (selectedDate) {
            setState(() {
              _selectedDate = selectedDate;
            });
          },
        ),
      );
    });
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

  void onChange(int index) {
    setState(() {
      selected[index].checkValue = !selected[index].checkValue;
    });
  }

  void _showTimePicker(var id) async {
    var value = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(_timeDelete.split(":")[0]),
            minute: int.parse(_timeDelete.split(":")[1].split(" ")[0])));
    if (value != null) {
      _controllerTimeDelete.text = value.format(context);
      FirebaseFirestore.instance
          .collection("NoteTask")
          .doc(id)
          .update({"TimeDelete": _controllerTimeDelete.text});
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => RecycleBin()),
          (route) => false);
    }
  }
}

TextStyle get subHeadingStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(221, 228, 122, 16)));
}

TextStyle get IconStyle {
  return GoogleFonts.lato(
      textStyle: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.bold,
          color: Color.fromARGB(221, 228, 122, 16)));
}

class Select {
  late String id;
  bool checkValue = false;
  Select(this.id, this.checkValue);
}

// leading: IconButton(
//             onPressed: () async {
//               await authClass.logOut();
//               Navigator.pushAndRemoveUntil(
//                   context,
//                   MaterialPageRoute(builder: (builder) => SignUpPage()),
//                   (route) => false);
//             },
//             icon: Icon(Icons.arrow_back)),


                                        // print(_selectedDate);
 