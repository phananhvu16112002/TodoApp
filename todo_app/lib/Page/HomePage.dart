import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/Custom/GridCard.dart';
import 'package:todo_app/Custom/NoteCard.dart';
import 'package:todo_app/Page/AddNewNote.dart';
import 'package:todo_app/Page/PhonePageAuth.dart';
import 'package:todo_app/Page/ProfilePage.dart';
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

import 'package:share_plus/share_plus.dart';

class HomePage extends StatefulWidget {
  final bool skipped;
  const HomePage({super.key, this.skipped = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Select> selected = [];
  AuthClass authClass = AuthClass();
  TextEditingController _searchController = TextEditingController();
  late QuerySnapshot _snapshotData;
  bool _isSearching = false;
  bool checkListView = true;
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _confirmPasswordController = TextEditingController();
  TextEditingController _unPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late List<Map<String, dynamic>> _noteList;
  late List<Map<String, dynamic>> _allNotes;
  DateTime _selectedDate = DateTime.now();
  DateTime dateChoose = DateTime.now();
  late var _noteStream;
  var notifyHelper = NotificationsService();
  int _selectedIndex = 0;
  String? selectedCategory;
  int index = 0;
  bool _isPinned = false;

  @override
  void dispose() {
    // TODO: implement dispose
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

    notifyHelper = NotificationsService();
    notifyHelper.initializeNotification();
    notifyHelper.requestIOSPermissions();

    super.initState();
    getUserData();
  }

  @override
  Widget build(BuildContext context) {
    var userID = FirebaseAuth.instance.currentUser?.uid;
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    String? userName = FirebaseAuth.instance.currentUser?.displayName;
    String? userPhone = FirebaseAuth.instance.currentUser?.phoneNumber;
    final List<String> categories = [
      "Work",
      "WorkOut",
      "Food",
      "Design",
      "Run"
    ];
    late String
        selectedCategory; // add this variable to the top of your widget tree
    selectedCategory = categories[0]; //

    bool completed = false;
    List<Map<String, dynamic>> pinnedNotes = [];
    Stream<QuerySnapshot> _stream = FirebaseFirestore.instance
        .collection("NoteTask")
        .where("userID", isEqualTo: userID)
        .snapshots();

    return Scaffold(
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (builder) => AddNewNote()));
            },
            child: Container(
                height: 55,
                width: 55,
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
                    child: Icon(Icons.add, size: 32, color: Colors.white)))),
        backgroundColor: Colors.black87,
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      hintText: "Search...",
                      hintStyle: TextStyle(color: Colors.white)),
                  onChanged: _searchNotes,
                )
              : Text("Today's Schedule",
                  style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
          // actions: _buildAppBarActions(),
          actions: [
            IconButton(
                onPressed: () => _showCategoryFilterDialog(),
                icon: Icon(Icons.filter_list))
          ],
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
                                                      .update(
                                                          {'isDeleted': true});
                                                }
                                              }
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          HomePage()));
                                              ;
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
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _isSearching = !_isSearching;
                              _searchController.clear();
                            });
                          },
                          icon: Icon(
                              _isSearching
                                  ? Icons.cancel_outlined
                                  : Icons.search,
                              size: 32,
                              color: Colors.white),
                        )
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
                          child: Image.asset('assets/avatar.jpg')),
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
                'Recycle Bin',
                style: TextStyle(fontSize: 16),
              ),
              trailing: Icon(Icons.recycling_outlined),
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (builder) => RecycleBin()));
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
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            backgroundColor: Colors.black87,
            onTap: (value) {
              setState(() {
                _selectedIndex = value;
              });
            },
            items: [
              BottomNavigationBarItem(
                icon: InkWell(
                    onTap: () {},
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
                          child:
                              Icon(Icons.add, size: 32, color: Colors.white))),
                  label: 'Add Note'),
              BottomNavigationBarItem(
                  icon: InkWell(
                      onTap: () {
                        notifyHelper.displayNotification(
                            title: 'title', body: 'body');
                        // notifyHelper.displayNotification(
                        //     title: "Theme Changed", body: "Go add");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => ProfilePage()));
                      },
                      child:
                          Icon(Icons.settings, size: 32, color: Colors.white)),
                  label: 'Settings'),
            ]),
        body: _isSearching
            ? _buildNotesListView()
            : SafeArea(
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
                    List<QueryDocumentSnapshot> filteredDocs = [];
                    for (int i = 0; i < docs.length; i++) {
                      var temp =
                          snapshot.data!.docs[i].data() as Map<String, dynamic>;
                      if (temp['isDeleted'] == false) {
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "All Notes",
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/note.jpg',
                                                width: 150, height: 150),
                                            Text('Create your notes',
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
                                          child:
                                              Text('Error: ${snapshot.error}'));
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    }
                                    return checkListView
                                        ? ListView.builder(
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: (context, index) {
                                              IconData iconData;
                                              Color iconColor;
                                              Map<String, dynamic> document =
                                                  snapshot.data!.docs[index]
                                                          .data()
                                                      as Map<String, dynamic>;
                                              if (document['Repeat'] == 'Daily')
                                                notifyHelper
                                                    .scheduledNotification(
                                                        int.parse(document[
                                                                'TimeStart']
                                                            .toString()
                                                            .split(":")[0]),
                                                        int.parse(document[
                                                                'TimeStart']
                                                            .toString()
                                                            .split(":")[1]),
                                                        document);

                                              switch (document['Category']) {
                                                case "Work":
                                                  iconData =
                                                      Icons.run_circle_outlined;
                                                  iconColor = Colors.red;
                                                  break;
                                                case "WorkOut":
                                                  iconData = Icons.alarm;
                                                  iconColor = Colors.purple;
                                                  break;
                                                case "Food":
                                                  iconData = Icons.food_bank;
                                                  iconColor = Colors.pink;
                                                  break;
                                                case "Design":
                                                  iconData = Icons
                                                      .design_services_outlined;
                                                  iconColor = Colors.teal;
                                                  break;
                                                case "Run":
                                                  iconData =
                                                      Icons.sports_esports;
                                                  iconColor = Color.fromARGB(
                                                      255, 199, 228, 36);
                                                  break;
                                                default:
                                                  iconData =
                                                      Icons.run_circle_outlined;
                                                  iconColor = Colors.red;
                                              }
                                              selected.add(Select(
                                                  snapshot.data!.docs[index].id,
                                                  false));
                                              return GestureDetector(
                                                  onLongPress: () {
                                                    setState(() {
                                                      _isPinned = !_isPinned;
                                                      document['Pinned'] =
                                                          _isPinned; // lưu trạng thái ghim vào firestore
                                                      // nếu cần, cập nhật trạng thái ghim trong danh sách của app
                                                    });
                                                  },
                                                  onTap:
                                                      document['Completed'] ||
                                                              document[
                                                                  'Protected']
                                                          ? () {}
                                                          : () {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder: (builder) => ViewNote(
                                                                          document:
                                                                              document,
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
                                                            onPressed:
                                                                (context) {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
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
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                Text("Cancel")),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              String id = snapshot.data!.docs[index].id;
                                                                              FirebaseFirestore.instance.collection("NoteTask").doc(id).update({
                                                                                'isDeleted': true,
                                                                              });
                                                                              Navigator.push(context, MaterialPageRoute(builder: (builder) => HomePage()));
                                                                            },
                                                                            child:
                                                                                Text('Delete'))
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            backgroundColor:
                                                                Color(
                                                                    0xFFFE4A49),
                                                            foregroundColor:
                                                                Colors.white,
                                                            icon: Icons.delete,
                                                            label: 'Delete',
                                                          ),
                                                          document['Completed']
                                                              ? SlidableAction(
                                                                  onPressed:
                                                                      (context) {
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
                                                                      'Completed':
                                                                          false,
                                                                    });
                                                                  },
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          202,
                                                                          35,
                                                                          199),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  icon: Icons
                                                                      .cancel,
                                                                  label:
                                                                      'UnComplete',
                                                                )
                                                              : SlidableAction(
                                                                  onPressed:
                                                                      (context) {
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
                                                                      'Completed':
                                                                          true,
                                                                    });
                                                                  },
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          44,
                                                                          137,
                                                                          190),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  icon: Icons
                                                                      .check,
                                                                  label:
                                                                      'Completed',
                                                                ),
                                                          SlidableAction(
                                                            onPressed:
                                                                (context) {
                                                              String notesText =
                                                                  '';
                                                              for (int i = 0;
                                                                  i <
                                                                      snapshot
                                                                          .data!
                                                                          .docs
                                                                          .length;
                                                                  i++) {
                                                                Map<String,
                                                                    dynamic> document = snapshot
                                                                        .data!
                                                                        .docs[i]
                                                                        .data()
                                                                    as Map<
                                                                        String,
                                                                        dynamic>;

                                                                String title = document[
                                                                        'title'] ??
                                                                    'Hey There';
                                                                String
                                                                    description =
                                                                    document[
                                                                            'description'] ??
                                                                        '';
                                                                String
                                                                    timeStart =
                                                                    document[
                                                                            'TimeStart'] ??
                                                                        '';
                                                                String
                                                                    timeFinish =
                                                                    document[
                                                                            'TimeFinish'] ??
                                                                        '';
                                                                String
                                                                    AudioNotes =
                                                                    document[
                                                                            'AudioNotes'] ??
                                                                        '';
                                                                String
                                                                    FileNotes =
                                                                    document[
                                                                            'FileNotes'] ??
                                                                        '';
                                                                String
                                                                    videoNotes =
                                                                    document[
                                                                        'VideoNotes'];
                                                                String
                                                                    DateFinish =
                                                                    document[
                                                                            'DateFinish'] ??
                                                                        '';
                                                                String repeat =
                                                                    document[
                                                                            'Repeat'] ??
                                                                        '';
                                                                String
                                                                    category =
                                                                    document[
                                                                            'Category'] ??
                                                                        '';

                                                                notesText +=
                                                                    'Name: $userName\n "Email:" $userEmail\n Title: ${title}\n Category: $category\n Description: $description\n TimeStart: $timeStart\n TimeFinish: $timeFinish\n DateFinish: $DateFinish\n AudioFiles: $AudioNotes\n ImageFiles: $FileNotes\n VideoFiles: $videoNotes \n Repeat:$repeat\n\n';
                                                              }
                                                              Share.share(
                                                                  'Here are my notes:\n\n$notesText',
                                                                  subject:
                                                                      'My Notes');
                                                            },
                                                            backgroundColor:
                                                                Color.fromARGB(
                                                                    255,
                                                                    193,
                                                                    23,
                                                                    57),
                                                            foregroundColor:
                                                                Colors.white,
                                                            icon: Icons.share,
                                                            label: 'Share',
                                                          ),
                                                          document['Protected']
                                                              ? SlidableAction(
                                                                  onPressed:
                                                                      (context) {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              Text('Protected password'),
                                                                          content:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              TextFormField(
                                                                                controller: _unPasswordController,
                                                                                obscureText: true,
                                                                                decoration: InputDecoration(labelText: "Enter Password", labelStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 33, 31, 31)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1.5, color: Color.fromARGB(255, 241, 159, 108))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1, color: Colors.grey)), hintText: 'Enter password'),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: Text('Cancel'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                if (_unPasswordController.text.trim() == document['Password']) {
                                                                                  String id = snapshot.data!.docs[index].id;
                                                                                  FirebaseFirestore.instance.collection('NoteTask').doc(id).update({
                                                                                    'Protected': false,
                                                                                    'Password': '',
                                                                                  });
                                                                                  Navigator.pop(context);
                                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unlock successfully")));
                                                                                } else {
                                                                                  setState(() {
                                                                                    _unPasswordController.text = '';
                                                                                  });
                                                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password is wrong! Please check!")));
                                                                                }
                                                                                setState(() {
                                                                                  _passwordController.text = '';
                                                                                  _confirmPasswordController.text = '';
                                                                                });
                                                                              },
                                                                              child: Text('Unlock'),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          48,
                                                                          48,
                                                                          176),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  icon: Icons
                                                                      .lock_clock_rounded,
                                                                  label:
                                                                      'UnProtect',
                                                                )
                                                              : SlidableAction(
                                                                  onPressed:
                                                                      (context) {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              Text('Set password'),
                                                                          content:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              TextFormField(
                                                                                controller: _passwordController,
                                                                                obscureText: true,
                                                                                decoration: InputDecoration(labelText: "Enter Password", labelStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 33, 31, 31)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1.5, color: Color.fromARGB(255, 241, 159, 108))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1, color: Colors.grey)), hintText: 'Enter password'),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              TextFormField(
                                                                                controller: _confirmPasswordController,
                                                                                obscureText: true,
                                                                                decoration: InputDecoration(labelText: "Confirm Password", labelStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 33, 31, 31)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1.5, color: Color.fromARGB(255, 241, 159, 108))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1, color: Colors.grey)), hintText: 'Confirm Password'),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: Text('Cancel'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                if (_passwordController.text.trim() == _confirmPasswordController.text.trim()) {
                                                                                  String id = snapshot.data!.docs[index].id;
                                                                                  String password = _passwordController.text.trim();
                                                                                  FirebaseFirestore.instance.collection('NoteTask').doc(id).update({
                                                                                    'Protected': true,
                                                                                    'Password': password,
                                                                                  });
                                                                                  Navigator.pop(context);
                                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lock successfully")));
                                                                                } else {
                                                                                  setState(() {
                                                                                    _confirmPasswordController.text = '';
                                                                                    _passwordController.text = '';
                                                                                  });
                                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password is wrong! Please check your password")));
                                                                                }
                                                                                setState(() {
                                                                                  _unPasswordController.text = '';
                                                                                });
                                                                              },
                                                                              child: Text('Set'),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          107,
                                                                          203,
                                                                          12),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  icon: Icons
                                                                      .lock,
                                                                  label:
                                                                      'Protect',
                                                                )
                                                        ]),
                                                    child: document[
                                                                'isDeleted'] ==
                                                            false
                                                        ? NoteCard(
                                                            title: document[
                                                                        'title'] ==
                                                                    null
                                                                ? "Hey There"
                                                                : document[
                                                                    'title'],
                                                            iconData: iconData,
                                                            colorIcon:
                                                                iconColor,
                                                            timeStart: document[
                                                                'TimeStart'],
                                                            check:
                                                                selected[index]
                                                                    .checkValue,
                                                            iconBGColor:
                                                                Colors.white,
                                                            index: index,
                                                            onChanged: onChange,
                                                            completed: document[
                                                                'Completed'],
                                                            timeFinish: document[
                                                                'TimeFinish'],
                                                            dateFinish: document[
                                                                'DateFinish'],
                                                            protected: document[
                                                                'Protected'],
                                                            description: document[
                                                                'decription'],
                                                            isDeleted: document[
                                                                'isDeleted'],
                                                            timeDelete: document[
                                                                'TimeDelete'],
                                                          )
                                                        : Container(),
                                                  ));
                                            })
                                        : GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount:
                                                  2, // Số cột trong lưới
                                            ),
                                            itemCount:
                                                snapshot.data!.docs.length,
                                            itemBuilder: (context, index) {
                                              IconData iconData;
                                              Color iconColor;
                                              Map<String, dynamic> document =
                                                  snapshot.data!.docs[index]
                                                          .data()
                                                      as Map<String, dynamic>;
                                              switch (document['Category']) {
                                                case "Work":
                                                  iconData =
                                                      Icons.run_circle_outlined;
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
                                                  iconData = Icons
                                                      .design_services_outlined;
                                                  iconColor = Colors.teal;
                                                  break;
                                                case "Run":
                                                  iconData =
                                                      Icons.sports_esports;
                                                  iconColor = Color.fromARGB(
                                                      255, 199, 228, 36);
                                                  break;
                                                default:
                                                  iconData =
                                                      Icons.run_circle_outlined;
                                                  iconColor = Colors.red;
                                              }
                                              selected.add(Select(
                                                  snapshot.data!.docs[index].id,
                                                  false));
                                              return InkWell(
                                                onTap: document['Completed'] ||
                                                        document['Protected']
                                                    ? () {}
                                                    : () {
                                                        Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder: (builder) => ViewNote(
                                                                    document:
                                                                        document,
                                                                    id: snapshot
                                                                        .data!
                                                                        .docs[
                                                                            index]
                                                                        .id)));
                                                      },
                                                child: Slidable(
                                                    key: const ValueKey(0),
                                                    endActionPane: ActionPane(
                                                        motion: ScrollMotion(),
                                                        children: [
                                                          SlidableAction(
                                                            onPressed:
                                                                (context) {
                                                              showDialog(
                                                                  context:
                                                                      context,
                                                                  builder:
                                                                      (BuildContext
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
                                                                              Navigator.of(context).pop();
                                                                            },
                                                                            child:
                                                                                Text("Cancel")),
                                                                        TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              String id = snapshot.data!.docs[index].id;
                                                                              FirebaseFirestore.instance.collection("NoteTask").doc(id).update({
                                                                                'isDeleted': true,
                                                                              });
                                                                              Navigator.push(context, MaterialPageRoute(builder: (builder) => HomePage()));
                                                                            },
                                                                            child:
                                                                                Text('Delete'))
                                                                      ],
                                                                    );
                                                                  });
                                                            },
                                                            backgroundColor:
                                                                Color(
                                                                    0xFFFE4A49),
                                                            foregroundColor:
                                                                Colors.white,
                                                            icon: Icons.delete,
                                                            label: 'Delete',
                                                          ),
                                                          document['Completed']
                                                              ? SlidableAction(
                                                                  onPressed:
                                                                      (context) {
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
                                                                      'Completed':
                                                                          false,
                                                                    });
                                                                  },
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          202,
                                                                          35,
                                                                          199),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  icon: Icons
                                                                      .cancel,
                                                                  label:
                                                                      'UnComplete',
                                                                )
                                                              : SlidableAction(
                                                                  onPressed:
                                                                      (context) {
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
                                                                      'Completed':
                                                                          true,
                                                                    });
                                                                  },
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          44,
                                                                          137,
                                                                          190),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  icon: Icons
                                                                      .check,
                                                                  label:
                                                                      'Completed',
                                                                ),
                                                          document['Protected']
                                                              ? SlidableAction(
                                                                  onPressed:
                                                                      (context) {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              Text('Protected password'),
                                                                          content:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              TextFormField(
                                                                                controller: _unPasswordController,
                                                                                obscureText: true,
                                                                                decoration: InputDecoration(labelText: "Enter Password", labelStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 33, 31, 31)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1.5, color: Color.fromARGB(255, 241, 159, 108))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1, color: Colors.grey)), hintText: 'Enter password'),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: Text('Cancel'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                if (_unPasswordController.text.trim() == document['Password']) {
                                                                                  String id = snapshot.data!.docs[index].id;
                                                                                  FirebaseFirestore.instance.collection('NoteTask').doc(id).update({
                                                                                    'Protected': false,
                                                                                    'Password': '',
                                                                                  });
                                                                                  Navigator.pop(context);
                                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Unlock successfully")));
                                                                                } else {
                                                                                  setState(() {
                                                                                    _unPasswordController.text = '';
                                                                                  });
                                                                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Password is wrong! Please check!")));
                                                                                }
                                                                                setState(() {
                                                                                  _passwordController.text = '';
                                                                                  _confirmPasswordController.text = '';
                                                                                });
                                                                              },
                                                                              child: Text('Unlock'),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          48,
                                                                          48,
                                                                          176),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  icon: Icons
                                                                      .lock_clock_rounded,
                                                                  label:
                                                                      'UnProtect',
                                                                )
                                                              : SlidableAction(
                                                                  onPressed:
                                                                      (context) {
                                                                    showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return AlertDialog(
                                                                          title:
                                                                              Text('Set password'),
                                                                          content:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: [
                                                                              TextFormField(
                                                                                controller: _passwordController,
                                                                                obscureText: true,
                                                                                decoration: InputDecoration(labelText: "Enter Password", labelStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 33, 31, 31)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1.5, color: Color.fromARGB(255, 241, 159, 108))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1, color: Colors.grey)), hintText: 'Enter password'),
                                                                              ),
                                                                              SizedBox(
                                                                                height: 10,
                                                                              ),
                                                                              TextFormField(
                                                                                controller: _confirmPasswordController,
                                                                                obscureText: true,
                                                                                decoration: InputDecoration(labelText: "Confirm Password", labelStyle: TextStyle(fontSize: 15, color: Color.fromARGB(255, 33, 31, 31)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1.5, color: Color.fromARGB(255, 241, 159, 108))), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(width: 1, color: Colors.grey)), hintText: 'Confirm Password'),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          actions: [
                                                                            TextButton(
                                                                              onPressed: () => Navigator.pop(context),
                                                                              child: Text('Cancel'),
                                                                            ),
                                                                            TextButton(
                                                                              onPressed: () {
                                                                                if (_passwordController.text.trim() == _confirmPasswordController.text.trim()) {
                                                                                  String id = snapshot.data!.docs[index].id;
                                                                                  String password = _passwordController.text.trim();
                                                                                  FirebaseFirestore.instance.collection('NoteTask').doc(id).update({
                                                                                    'Protected': true,
                                                                                    'Password': password,
                                                                                  });
                                                                                  Navigator.pop(context);
                                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Lock successfully")));
                                                                                } else {
                                                                                  setState(() {
                                                                                    _confirmPasswordController.text = '';
                                                                                    _passwordController.text = '';
                                                                                  });
                                                                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Password is wrong! Please check your password")));
                                                                                }
                                                                                setState(() {
                                                                                  _unPasswordController.text = '';
                                                                                });
                                                                              },
                                                                              child: Text('Set'),
                                                                            ),
                                                                          ],
                                                                        );
                                                                      },
                                                                    );
                                                                  },
                                                                  backgroundColor:
                                                                      Color.fromARGB(
                                                                          255,
                                                                          107,
                                                                          203,
                                                                          12),
                                                                  foregroundColor:
                                                                      Colors
                                                                          .white,
                                                                  icon: Icons
                                                                      .lock,
                                                                  label:
                                                                      'Protect',
                                                                ),
                                                        ]),
                                                    child: document[
                                                                'isDeleted'] ==
                                                            false
                                                        ? GridCard(
                                                            title: document[
                                                                        'title'] ==
                                                                    null
                                                                ? "Hey There"
                                                                : document[
                                                                    'title'],
                                                            iconData: iconData,
                                                            colorIcon:
                                                                iconColor,
                                                            timeStart: document[
                                                                'TimeFinish'],
                                                            check:
                                                                selected[index]
                                                                    .checkValue,
                                                            iconBGColor:
                                                                Colors.white,
                                                            index: index,
                                                            onChanged: onChange,
                                                            completed: document[
                                                                'Completed'],
                                                            timeFinish: document[
                                                                'TimeFinish'],
                                                            dateFinish: document[
                                                                'DateFinish'],
                                                            protected: document[
                                                                'Protected'],
                                                          )
                                                        : Container()),
                                              );
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

  void _showCategoryFilterDialog() async {
    String? selectedCategoryResult = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filter by Category"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text("All"),
                  onTap: () {
                    Navigator.of(context).pop("All");
                  },
                ),
                SizedBox(height: 8),
                GestureDetector(
                  child: Text("Work"),
                  onTap: () {
                    Navigator.of(context).pop("Work");
                  },
                ),
                SizedBox(height: 8),
                GestureDetector(
                  child: Text("WorkOut"),
                  onTap: () {
                    Navigator.of(context).pop("WorkOut");
                  },
                ),
                SizedBox(height: 8),
                GestureDetector(
                  child: Text("Food"),
                  onTap: () {
                    Navigator.of(context).pop("Food");
                  },
                ),
                SizedBox(height: 8),
                GestureDetector(
                  child: Text("Design"),
                  onTap: () {
                    Navigator.of(context).pop("Design");
                  },
                ),
                SizedBox(height: 8),
                GestureDetector(
                  child: Text("Run"),
                  onTap: () {
                    Navigator.of(context).pop("Run");
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedCategoryResult != null) {
      setState(() {
        selectedCategory = selectedCategoryResult;
      });
    }
  }

  // List<Widget> _buildAppBarActions() {
  //   if (_isSearching) {
  //     return [];
  //   } else {
  //     return [
  //       PopupMenuButton<String>(
  //         onSelected: (category) {},
  //         itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
  //           PopupMenuItem<String>(
  //             value: 'All',
  //             child: Text('All'),
  //           ),
  //           PopupMenuItem<String>(
  //             value: 'Work',
  //             child: Text('Work'),
  //           ),
  //           PopupMenuItem<String>(
  //             value: 'WorkOut',
  //             child: Text('WorkOut'),
  //           ),
  //           PopupMenuItem<String>(
  //             value: 'Food',
  //             child: Text('Food'),
  //           ),
  //           PopupMenuItem<String>(
  //             value: 'Design',
  //             child: Text('Design'),
  //           ),
  //           PopupMenuItem<String>(
  //             value: 'Run',
  //             child: Text('Run'),
  //           ),
  //         ],
  //       ),
  //     ];
  //   }
  // }

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

  void _onPressedComplete(String noteId) {
    FirebaseFirestore.instance
        .collection("NoteTask")
        .doc(noteId)
        .update({'Completed': true})
        .then((value) => print("Note Updated"))
        .catchError((error) => print("Failed to update note: $error"));
  }

  void _searchNotes(String query) {
    List<Map<String, dynamic>> results = [];
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _noteList = _allNotes;
      });
    } else {
      FirebaseFirestore.instance
          .collection('NoteTask')
          .orderBy('title')
          .startAt([query])
          .endAt([query + '\uf8ff'])
          .get()
          .then((QuerySnapshot snapshot) {
            setState(() {
              _noteList = snapshot.docs
                  .map((e) => e.data() as Map<String, dynamic>)
                  .toList();
              _isSearching = true;
            });
          });
    }
  }

  Widget _buildNotesListView() {
    return ListView.builder(
      itemCount: _noteList.length,
      itemBuilder: (BuildContext context, int index) {
        Map<String, dynamic> noteData = _noteList[index];
        var timeStart = noteData['TimeStart'].toString();
        var timeFinish = noteData['TimeFinish'].toString();
        return Card(
          elevation: 4,
          color: Color(0xff2a2e3d),
          child: ListTile(
            leading: Icon(
              Icons.note_outlined,
              color: Colors.white,
              size: 30,
            ),
            trailing: Icon(
              Icons.arrow_circle_right,
              color: Colors.white,
              size: 30,
            ),
            title: Text(
              noteData['title'].toString(),
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              "$timeStart -  $timeFinish",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewNote(
                    document: noteData,
                    id: index.toString(),
                  ),
                ),
              );
            },
          ),
        );
      },
      controller: ScrollController(initialScrollOffset: _selectedIndex * 80.0),
    );
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
