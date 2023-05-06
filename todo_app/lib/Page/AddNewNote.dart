import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/Custom/MyInputFeild.dart';
import 'package:todo_app/Page/HomePage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class AddNewNote extends StatefulWidget {
  final int count = 0;
  const AddNewNote({
    super.key,
  });

  @override
  State<AddNewNote> createState() => _AddNewNoteState();
}

class _AddNewNoteState extends State<AddNewNote> {
  var selectedDate = DateTime.now();
  var _controllerDateTime = TextEditingController();
  var _noteTitleController = TextEditingController();
  var _noteDescriptionController = TextEditingController();
  var _controllerTimeStart = TextEditingController();
  var _controllerTimeFinish = TextEditingController();
  var userID = FirebaseAuth.instance.currentUser?.uid;
  String _finishTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  bool completed = false;
  bool protected = false;
  bool pinned = false;
  bool isDeleted = false;
  String _selectedRepeat = "None";
  List<String> repeatList = ["None", "Daily"];
  String password = '';
  var noteType = '';
  var noteCategory = '';
  bool isCheckImage = false;
  bool isCheckAudio = false;
  bool isCheckVideo = false;
  PlatformFile? pickedImageFile;
  PlatformFile? pickedAudioFile;
  PlatformFile? pickedVideoFile;
  UploadTask? uploadImageTask;
  UploadTask? uploadAudioTask;
  UploadTask? uploadVideoTask;

  var fileNotes;
  var audioNotes;
  var videoNotes;
  bool isPlaying = false;
  double duration = 0.0;
  double position = 0.0;
  FlutterSoundPlayer? _audioPlayer;
  AudioPlayer? _audioplayersPlayer;
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  List<String> _userLabels = [];
  final colors = [0xFF9A2B3D, 0xFF27C27F, 0xFFDFB43C, 0xFF633997, 0xFFBA3286];
  int count = 0;

  void _getUserLabels() async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .where('userID', isEqualTo: userID);

    final userQuerySnapshot = await userRef.get();
    if (userQuerySnapshot.docs.isNotEmpty) {
      final userDoc = userQuerySnapshot.docs[0];
      final userLabels = userDoc.data()?['labels'];

      setState(() {
        _userLabels = List<String>.from(userLabels);
      });
    } else {
      // Handle the case where the query returns no documents
      setState(() {
        _userLabels = [];
      });
    }
  }

  Future selectImagesFile() async {
    if (isCheckImage) {
      return; // file picker is already open
    }

    final results = await FilePicker.platform.pickFiles(type: FileType.image);
    if (results == null) return;

    setState(() {
      isCheckImage = true;
      pickedImageFile = results.files.first;
    });
  }

  Future uploadImagesFile() async {
    final path = 'files/${pickedImageFile!.name}';
    final file = File(pickedImageFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadImageTask = ref.putFile(file);
    });

    final snapshot = await uploadImageTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');
    setState(() {
      fileNotes = urlDownload;
      uploadImageTask = null;
    });
  }

  Future selectAudioFiles() async {
    if (isCheckAudio) {
      return; // file picker is already open
    }
    final results = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (results == null) return;

    setState(() {
      isCheckAudio = true;
      pickedAudioFile = results.files.first;
      _audioPlayer = FlutterSoundPlayer();
      _audioPlayer!.openAudioSession();
    });
    // print(" ----------------------------------------- ${pickedAudioFile!.path!}");
  }

  Future uploadAudioFile() async {
    final path = 'audios/${pickedAudioFile!.name}';
    final file = File(pickedAudioFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadAudioTask = ref.putFile(file);
    });

    final snapshot = await uploadAudioTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    final uri = Uri.parse(urlDownload);
    final fileName = uri.pathSegments.last;
    print('Download Link: $urlDownload');
    setState(() {
      audioNotes = urlDownload;
      uploadAudioTask = null;
    });
  }

  Future selectVideoFile() async {
    if (isCheckVideo) {
      return; // file picker is already open
    }
    final results = await FilePicker.platform.pickFiles(type: FileType.video);
    if (results == null) return;

    setState(() {
      isCheckVideo = true;
      pickedVideoFile = results.files.first;
    });
    print(pickedVideoFile);
  }

  Future uploadVideoFile() async {
    final path = 'videos/${pickedVideoFile!.name}';
    final file = File(pickedVideoFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadVideoTask = ref.putFile(file);
      _videoPlayerController = VideoPlayerController.file(file)..initialize();
    });

    final snapshot = await uploadVideoTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    final uri = Uri.parse(urlDownload);
    final fileName = uri.pathSegments.last;
    print('Download Link: $urlDownload');
    setState(() {
      videoNotes = urlDownload;
      uploadVideoTask = null;
    });

    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        allowFullScreen: false,
        looping: false);
  }

  void pauseAudio() async {
    await _audioPlayer!.pausePlayer();
    setState(() {
      isPlaying = false;
    });
  }

  void playAudio() async {
    await _audioPlayer!.startPlayer(
      fromURI: audioNotes!,
      whenFinished: () {
        setState(() {
          isPlaying = false;
          position = duration;
        });
      },
    );

    setState(() {
      isPlaying = true;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
    }

    if (_chewieController != null) {
      _chewieController!.dispose();
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLabels();
  }

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

                      /////////////////////Pick Images ///////////////////////
                      label("Pick Images"),
                      SizedBox(
                        height: 2,
                      ),
                      Column(
                        children: [
                          if (pickedImageFile != null)
                            Container(
                                child: Image.file(
                              File(pickedImageFile!.path!),
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover,
                            )),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 190, 59, 35)),
                                  child: const Text('Selected Image'),
                                  onPressed: selectImagesFile),
                              SizedBox(width: 25),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: isCheckImage
                                          ? Colors.green
                                          : Colors.grey),
                                  child: const Text('Upload Image'),
                                  onPressed:
                                      isCheckImage ? uploadImagesFile : () {}),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      /////////////////Pick Audio////////////////////
                      label("Pick Audio"),
                      SizedBox(
                        height: 2,
                      ),
                      Column(
                        children: [
                          if (pickedAudioFile != null)
                            ListTile(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    width: 2,
                                    color: Color.fromARGB(255, 20, 148, 99)),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              leading: IconButton(
                                onPressed: () {
                                  if (audioNotes != null &&
                                      _audioPlayer != null) {
                                    if (!isPlaying) {
                                      playAudio();
                                    } else {
                                      pauseAudio();
                                    }
                                  }
                                },
                                icon: Icon(
                                    isPlaying ? Icons.pause : Icons.play_arrow),
                                iconSize: 20,
                                color: Colors.white,
                              ),
                              title: Text(
                                  pickedAudioFile!.path!.split("/").last,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                              trailing: IconButton(
                                onPressed: () {
                                  pauseAudio();
                                },
                                icon: Icon(Icons.pause),
                                iconSize: 20,
                                color: Colors.white,
                              ),
                            ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Color.fromARGB(255, 40, 12, 154)),
                                  child: const Text('Selected Audio'),
                                  onPressed: selectAudioFiles),
                              SizedBox(width: 25),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: isCheckAudio
                                          ? Colors.green
                                          : Colors.grey),
                                  child: const Text('Upload Audio'),
                                  onPressed:
                                      isCheckAudio ? uploadAudioFile : () {}),
                            ],
                          ),
                        ],
                      ),
                      ////////////////////Pick Video/////////////////////////
                      SizedBox(
                        height: 25,
                      ),
                      label("Pick Video"),
                      SizedBox(
                        height: 2,
                      ),

                      const SizedBox(height: 12),
                      Column(
                        children: [
                          _chewieController == null
                              ? Container()
                              : Chewie(controller: _chewieController!),
                          Row(
                            children: [
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber),
                                  child: const Text('Selected Video'),
                                  onPressed: selectVideoFile),
                              SizedBox(width: 25),
                              ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: isCheckVideo
                                          ? Colors.green
                                          : Colors.grey),
                                  child: const Text('Upload Video'),
                                  onPressed:
                                      isCheckVideo ? uploadVideoFile : () {}),
                            ],
                          ),
                        ],
                      ),

                      SizedBox(
                        height: 25,
                      ),
                      label("Category"),
                      SizedBox(
                        height: 25,
                      ),
                      Wrap(
                        runSpacing: 10,
                        spacing: 20,
                        children: [
                          for (int i = 0; i < _userLabels.length; i++)
                            categorySelect(
                                _userLabels[i], colors[i % colors.length]),
                          categorySelect("Food", 0xFF575A4F),
                          categorySelect("Work", 0xFF4283C4),
                          categorySelect("WorkOut", 0xFFDFB43C),
                          categorySelect("Design", 0xFF633997),
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
            "FileNotes": fileNotes.toString(),
            "AudioNotes": audioNotes.toString(),
            "VideoNotes": videoNotes.toString(),
            "DateFinish": _controllerDateTime.text,
            "TimeStart": _controllerTimeStart.text,
            "TimeFinish": _controllerTimeFinish.text,
            "isDeleted": isDeleted,
            "TimeDelete": '',
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
          count++;
        } else if (_noteTitleController.text.isEmpty ||
            _noteDescriptionController.text.isEmpty ||
            _controllerTimeStart.text.isEmpty ||
            fileNotes.toString().isEmpty ||
            audioNotes.toString().isEmpty ||
            videoNotes.toString().isEmpty ||
            _controllerTimeFinish.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Please enter all your note ")));
        }
      },
      child: _noteTitleController.text.isNotEmpty &&
              _noteDescriptionController.text.isNotEmpty &&
              _controllerTimeStart.text.isNotEmpty &&
              _controllerTimeFinish.text.isNotEmpty &&
              fileNotes.toString().isNotEmpty &&
              audioNotes.toString().isNotEmpty &&
              videoNotes.toString().isNotEmpty
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
