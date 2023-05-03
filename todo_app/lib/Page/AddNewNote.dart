import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/Custom/MyInputFeild.dart';
import 'package:todo_app/Page/HomePage.dart';
import 'package:get/get.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class AddNewNote extends StatefulWidget {
  const AddNewNote({super.key});

  @override
  State<AddNewNote> createState() => _AddNewNoteState();
}

class _AddNewNoteState extends State<AddNewNote> {
  var selectedDate = DateTime.now();
  var _controllerDateTime = TextEditingController();
  var _noteTitleController = TextEditingController();
  var noteType = '';
  var _noteDescriptionController = TextEditingController();
  var _controllerTimeStart = TextEditingController();
  var _controllerTimeFinish = TextEditingController();
  var noteCategory = '';
  var userID = FirebaseAuth.instance.currentUser?.uid;
  String _finishTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  bool completed = false;
  bool protected = false;
  String password = '';
  bool pinned = false;

  String _selectedRepeat = "None";
  List<String> repeatList = ["None", "Daily"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
              Color(0xff1d1e26),
              Color(0xff252041),
            ])),
            child: SingleChildScrollView(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 30,
                ),
                IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      CupertinoIcons.arrow_left,
                      color: Colors.white,
                      size: 28,
                    )),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Create",
                          style: TextStyle(
                              fontSize: 33,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4)),
                      SizedBox(
                        height: 8,
                      ),
                      Text("New Note",
                          style: TextStyle(
                              fontSize: 33,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2)),
                      SizedBox(
                        height: 25,
                      ),
                      label("Task Title"),
                      SizedBox(
                        height: 12,
                      ),
                      title(),
                      SizedBox(
                        height: 30,
                      ),
                      label('Task Type'),
                      SizedBox(
                        height: 12,
                      ),
                      Row(
                        children: [
                          taskType("Important", 0xffff6d6e),
                          SizedBox(
                            width: 20,
                          ),
                          taskType("Planned", 0xFF6DFFB6),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      label("Note Description"),
                      SizedBox(
                        height: 12,
                      ),
                      noteDescription(),
                      SizedBox(
                        height: 25,
                      ),
                      label("Category"),
                      SizedBox(
                        height: 12,
                      ),
                      Wrap(
                        runSpacing: 10,
                        children: [
                          categorySelect("Food", 0xFF575A4F),
                          SizedBox(
                            width: 20,
                          ),
                          categorySelect("Work", 0xFF4283C4),
                          SizedBox(
                            width: 20,
                          ),
                          categorySelect("WorkOut", 0xFFDFB43C),
                          SizedBox(
                            width: 20,
                          ),
                          categorySelect("Design", 0xFF633997),
                          SizedBox(
                            width: 20,
                          ),
                          categorySelect("Run", 0xFFBA3286),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      label("Date Note Finish"),
                      SizedBox(
                        height: 12,
                      ),
                      DateTimePicker(),
                      SizedBox(
                        height: 12,
                      ),
                      label("Time Start"),
                      SizedBox(
                        height: 12,
                      ),
                      TimePicker(_controllerTimeStart),
                      SizedBox(
                        height: 12,
                      ),
                      label("End Time"),
                      SizedBox(
                        height: 12,
                      ),
                      TimeFinish(_controllerTimeFinish),
                      SizedBox(
                        height: 12,
                      ),
                      label("Remind"),
                      SizedBox(
                        height: 12,
                      ),
                      MyInputFeild(
                        title: "Remind",
                        hint: "$_selectedRemind minutes early",
                        widget: DropdownButton(
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey),
                          iconSize: 32,
                          elevation: 4,
                          style: IconStyle,
                          underline: Container(height: 0),
                          items: remindList
                              .map<DropdownMenuItem<String>>((int value) {
                            return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(
                                  value.toString(),
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ));
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedRemind = int.parse(value!);
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      label("Repeat"),
                      SizedBox(
                        height: 12,
                      ),
                      MyInputFeild(
                        title: "Repeat",
                        hint: "$_selectedRepeat",
                        widget: DropdownButton(
                          icon: Icon(Icons.keyboard_arrow_down,
                              color: Colors.grey),
                          iconSize: 32,
                          elevation: 4,
                          style: IconStyle,
                          underline: Container(height: 0),
                          items: repeatList
                              .map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value!,
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ));
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              _selectedRepeat = value!;
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        height: 50,
                      ),
                      buttonAddNote(),
                      SizedBox(
                        height: 30,
                      )
                    ],
                  ),
                )
              ],
            ))));
  }

  void _showDateTimeDialog() async {
    final DateTime currentDate = DateTime.now();
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate,
      lastDate: DateTime(currentDate.year + 10),
    );

    if (selectedDate != null) {
      _controllerDateTime.text = DateFormat('dd/MM/yyyy').format(selectedDate);
    } else {
      print("It's null or something is wrong");
    }
  }

  Widget TimePicker(TextEditingController controller) {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Color(0xff2a2e3d), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        onTap: () {
          _showTimePicker();
        },
        controller: controller,
        style: TextStyle(color: Colors.white, fontSize: 17),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: _startTime,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 17),
            contentPadding: EdgeInsets.only(
              left: 20,
              right: 20,
            )),
      ),
    );
  }

  Widget TimeFinish(TextEditingController controller) {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Color(0xff2a2e3d), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        onTap: () {
          _showTimePickerFinish();
        },
        controller: controller,
        style: TextStyle(color: Colors.white, fontSize: 17),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: _startTime,
            hintStyle: TextStyle(color: Colors.grey, fontSize: 17),
            contentPadding: EdgeInsets.only(
              left: 20,
              right: 20,
            )),
      ),
    );
  }

  Widget DateTimePicker() {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Color(0xff2a2e3d), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        readOnly: widget == null ? false : true,
        autofocus: false,
        onTap: () {
          _showDateTimeDialog();
        },
        controller: _controllerDateTime,
        style: TextStyle(color: Colors.white, fontSize: 17),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: DateFormat.yMd().format(DateTime.now()),
            hintStyle: TextStyle(color: Colors.grey, fontSize: 17),
            contentPadding: EdgeInsets.only(
              left: 20,
              right: 20,
            )),
      ),
    );
  }

  Widget buttonAddNote() {
    return InkWell(
      onTap: () {
        if (_noteTitleController.text.isNotEmpty &&
            _noteDescriptionController.text.isNotEmpty) {
          FirebaseFirestore.instance.collection("NoteTask").add({
            "title": _noteTitleController.text,
            "task": noteType,
            "Category": noteCategory,
            "decription": _noteDescriptionController.text,
            "DateFinish": _controllerDateTime.text,
            "TimeStart": _controllerTimeStart.text,
            "TimeFinish": _controllerTimeFinish.text,
            "Remind": _selectedRemind,
            "Repeat": _selectedRepeat,
            "Completed": completed,
            "Password": password,
            "Protected": protected,
            "Pinned": pinned,
            "userID": userID
          });
          setState(() {
            _noteTitleController.text = '';
            _noteDescriptionController.text = '';
            _controllerDateTime.text = '';
            _controllerTimeStart.text = '';
            _controllerTimeFinish.text = '';
            _selectedRemind = 5;
            _selectedRepeat = "None";
          });
          Navigator.push(
              context, MaterialPageRoute(builder: (builder) => HomePage()));
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Add Note Successfully")));
        } else if (_noteTitleController.text.isEmpty ||
            _noteDescriptionController.text.isEmpty || _controllerTimeStart.text.isEmpty || _controllerTimeFinish.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Required add Title and Description and Time Start and Finish ")));
        }
      },
      child: _noteTitleController.text.isNotEmpty && _noteDescriptionController.text.isNotEmpty && _controllerTimeStart.text.isNotEmpty && _controllerTimeFinish.text.isNotEmpty
          ? Container(
              height: 56,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                      colors: [Color(0xff8a32f1), Color(0xffad32f9)])),
              child: Center(
                child: Text(
                  "Add New Note",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600),
                ),
              ))
          : Container(),
    );
  }

  Widget taskType(String label, int color) {
    return InkWell(
      onTap: () {
        setState(() {
          noteType = label;
        });
      },
      child: Chip(
        backgroundColor: noteType == label ? Colors.white : Color(color),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
          10,
        )),
        label: Text(label),
        labelStyle: TextStyle(
          color: noteType == label ? Colors.black87 : Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        labelPadding: EdgeInsets.symmetric(horizontal: 17, vertical: 3.8),
      ),
    );
  }

  Widget categorySelect(String label, int color) {
    return InkWell(
      onTap: () {
        setState(() {
          noteCategory = label;
        });
      },
      child: Chip(
        backgroundColor: noteCategory == label ? Colors.white : Color(color),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
          10,
        )),
        label: Text(label,
            style: TextStyle(
              color: noteCategory == label ? Colors.black87 : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            )),
        labelPadding: EdgeInsets.symmetric(horizontal: 17, vertical: 3.8),
      ),
    );
  }

  Widget title() {
    return Container(
      height: 55,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Color(0xff2a2e3d), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: _noteTitleController,
        style: TextStyle(color: Colors.white, fontSize: 17),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Note title",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 17),
            contentPadding: EdgeInsets.only(
              left: 20,
              right: 20,
            )),
      ),
    );
  }

  Widget noteDescription() {
    return Container(
      height: 150,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Color(0xff2a2e3d), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: _noteDescriptionController,
        style: TextStyle(color: Colors.white, fontSize: 17),
        maxLines: null,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "Note Description",
            hintStyle: TextStyle(color: Colors.grey, fontSize: 17),
            contentPadding: EdgeInsets.only(
              left: 20,
              right: 20,
            )),
      ),
    );
  }

  Widget label(String label) {
    return Text(
      label,
      style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 16.5,
          letterSpacing: 2),
    );
  }

  // void _showTimePicker() async {
  //   final TimeOfDay? selectedTime = await showTimePicker(
  //     initialEntryMode: TimePickerEntryMode.input,
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //     builder: (BuildContext context, Widget? child) {
  //       return MediaQuery(
  //         data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (selectedTime != null) {
  //     final MaterialLocalizations localizations =
  //         MaterialLocalizations.of(context);
  //     final String formattedTime = localizations.formatTimeOfDay(selectedTime,
  //         alwaysUse24HourFormat: false);
  //     _controllerTimeStart.text = formattedTime;
  //   }
  // }

  void _showTimePicker() async {
    var value = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(_startTime.split(":")[0]),
            minute: int.parse(_startTime.split(":")[1].split(" ")[0])));
    if (value != null) {
      _controllerTimeStart.text = value.format(context);
    }
  }

  void _showTimePickerFinish() async {
    var value = await showTimePicker(
        initialEntryMode: TimePickerEntryMode.input,
        context: context,
        initialTime: TimeOfDay(
            hour: int.parse(_finishTime.split(":")[0]),
           minute: int.parse(_finishTime.split(":")[1].split(" ")[0])));
    if (value != null) {
      _controllerTimeFinish.text = value.format(context);
    }
  }
}
