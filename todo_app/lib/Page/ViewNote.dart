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

class ViewNote extends StatefulWidget {
  ViewNote({super.key, required this.document, required this.id});
  final Map<String, dynamic> document;
  final String id;

  @override
  State<ViewNote> createState() => _ViewNoteState();
}

class _ViewNoteState extends State<ViewNote> {
  var selectedDate = DateTime.now();
  var _controllerDateTime;
  var _noteTitleController;
  var noteType;
  var _noteDescriptionController;
  var _controllerTimeStart = TextEditingController();
  var _controllerTimeFinish = TextEditingController();
  var _controllerRemind = TextEditingController();
  var noteCategory;
  bool edit = false;
  String _finishTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  String _startTime = DateFormat("hh:mm a").format(DateTime.now()).toString();
  int _selectedRemind = 5;
  List<int> remindList = [5, 10, 15, 20];
  String _selectedRepeat = "None";
  List<String> repeatList = ["None", "Daily"];
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  UploadTask? uploadVideoTask;
  PlatformFile? pickedAudioFile;
  UploadTask? uploadAudioTask;
  bool isCheckAudio = false;
  bool isCheck = false;
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
  PlatformFile? pickedVideoFile;
  bool isCheckVideo = false;

  final storage = FirebaseStorage.instance;
  final AudioPlayer audioPlayer = AudioPlayer();

// Load and play the audio file from Firebase Storage
  Future<void> playAudioFromFirebase(String audioUrl) async {
    if (audioUrl != null) {
      final ref = storage.refFromURL(audioUrl);
      final url = await ref.getDownloadURL();
      await audioPlayer.play(url);
    }
  }

  Future uploadImagesFile() async {
    final path = 'files/${pickedFile!.name}';
    final file = File(pickedFile!.path!);

    final ref = FirebaseStorage.instance.ref().child(path);
    setState(() {
      uploadTask = ref.putFile(file);
    });

    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print('Download Link: $urlDownload');
    setState(() {
      fileNotes = urlDownload;
      uploadTask = null;
    });
  }

  Future selectImagesFile() async {
    final results = await FilePicker.platform.pickFiles(type: FileType.image);
    if (results == null) return;

    setState(() {
      isCheck = true;
      pickedFile = results.files.first;
    });
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
    print('Download Link: $urlDownload');
    setState(() {
      audioNotes = urlDownload;
      uploadAudioTask = null;
    });
  }

  Future selectAudioFiles() async {
    final results = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (results == null) return;

    setState(() {
      isCheckAudio = true;
      pickedAudioFile = results.files.first;
      _audioPlayer = FlutterSoundPlayer();
      _audioPlayer!.openAudioSession();
    });
  }

  Future selectVideoFile() async {
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
        looping: true);
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
  void initState() {
    super.initState();
    String title = widget.document['title'] == null
        ? "Hey There"
        : widget.document['title'];
    _noteTitleController = TextEditingController(text: title);
    _noteDescriptionController =
        TextEditingController(text: widget.document['decription']);
    noteType = widget.document['task'];
    noteCategory = widget.document['Category'];
    _controllerTimeStart =
        TextEditingController(text: widget.document['TimeStart']);
    _controllerTimeFinish =
        TextEditingController(text: widget.document['TimeFinish']);
    _controllerDateTime =
        TextEditingController(text: widget.document['DateFinish']);
    _selectedRemind = widget.document['Remind'];
    _selectedRepeat = widget.document['Repeat'];
    fileNotes = widget.document['FileNotes'];
    audioNotes = widget.document['AudioNotes'];
    videoNotes = widget.document['VideoNotes'];
    _videoPlayerController = VideoPlayerController.network("${videoNotes!}");
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: true);
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          CupertinoIcons.arrow_left,
                          color: Colors.white,
                          size: 28,
                        )),
                    Row(
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
                                              FirebaseFirestore.instance
                                                  .collection("NoteTask")
                                                  .doc(widget.id)
                                                  .delete()
                                                  .then((value) {});
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (builder) =>
                                                          HomePage()));
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(SnackBar(
                                                      content: Text(
                                                          "Deleted Note Successfully")));
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
                                edit = !edit;
                              });
                            },
                            icon: Icon(
                              Icons.edit,
                              color: edit ? Colors.green : Colors.white,
                              size: 28,
                            )),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(edit ? "Editing" : "View",
                          style: TextStyle(
                              fontSize: 33,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4)),
                      SizedBox(
                        height: 8,
                      ),
                      Text("Your Note",
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
                      label("Pick Images"),
                      SizedBox(
                        height: 12,
                      ),
                      Column(
                        children: [
                          if (widget.document['FileNotes'] != null)
                            Container(
                                child: Image.network(
                              '$fileNotes',
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              fit: BoxFit.cover,
                            )),
                          const SizedBox(height: 12),
                          Row(
                            children: edit
                                ? [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: edit
                                                ? Colors.amber
                                                : Colors.grey),
                                        child: const Text('Selected File'),
                                        onPressed:
                                            edit ? selectImagesFile : () {}),
                                    SizedBox(width: 25),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: edit && isCheck
                                                ? Colors.green
                                                : Colors.grey),
                                        child: const Text('Upload File'),
                                        onPressed: edit && isCheck
                                            ? uploadImagesFile
                                            : () {}),
                                  ]
                                : [],
                          ),
                        ],
                      ),
                      label("Pick Audio"),
                      SizedBox(
                        height: 12,
                      ),
                      Column(
                        children: edit
                            ? [
                                if (pickedAudioFile == null)
                                  ListTile(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 2, color: Colors.amberAccent),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    leading: IconButton(
                                        onPressed: () async {
                                          await playAudioFromFirebase(
                                              audioNotes);
                                        },
                                        icon: Icon(Icons.play_arrow),
                                        iconSize: 20,
                                        color: Colors.white),
                                    title: Text(
                                      '${Uri.parse("$audioNotes").pathSegments.last.split("/")[1]}',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.pause),
                                      iconSize: 20,
                                      color: Colors.white,
                                      onPressed: () {
                                        audioPlayer.stop();
                                      },
                                    ),
                                  ),
                                if (pickedAudioFile != null)
                                  ListTile(
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                          width: 2, color: Colors.amberAccent),
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
                                      icon: Icon(isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow),
                                      iconSize: 20,
                                      color: Colors.white,
                                    ),
                                    title: Text(
                                        '${Uri.parse("$audioNotes").pathSegments.last.split("/")[1]}',
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
                                            backgroundColor: Colors.amber),
                                        child: const Text('Selected File'),
                                        onPressed: selectAudioFiles),
                                    SizedBox(width: 25),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: isCheckAudio
                                                ? Colors.green
                                                : Colors.grey),
                                        child: const Text('Upload File'),
                                        onPressed: isCheckAudio
                                            ? uploadAudioFile
                                            : () {}),
                                  ],
                                ),
                              ]
                            : [
                                ListTile(
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 2, color: Colors.amberAccent),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  leading: IconButton(
                                      onPressed: () async {
                                        await playAudioFromFirebase(audioNotes);
                                      },
                                      icon: Icon(Icons.play_arrow),
                                      iconSize: 20,
                                      color: Colors.white),
                                  title: Text(
                                    '${Uri.parse("$audioNotes").pathSegments.last.split("/")[1]}',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(Icons.pause),
                                    iconSize: 20,
                                    color: Colors.white,
                                    onPressed: () {
                                      audioPlayer.stop();
                                    },
                                  ),
                                )
                              ],
                      ),
                      SizedBox(
                        height: 25,
                      ),
                      label("Pick Video"),
                      SizedBox(
                        height: 2,
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: edit
                            ? [
                                _chewieController == null
                                    ? Container()
                                    : Chewie(controller: _chewieController!),
                                Row(
                                  children: [
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: Color.fromARGB(255, 255, 7, 7)),
                                        child: const Text('Selected Video'),
                                        onPressed: selectVideoFile),
                                    SizedBox(width: 25),
                                    ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: isCheckVideo
                                                ? Colors.green
                                                : Colors.grey),
                                        child: const Text('Upload Video'),
                                        onPressed: isCheckVideo
                                            ? uploadVideoFile
                                            : () {}),
                                  ],
                                ),
                              ]
                            : [Chewie(controller: _chewieController!)],
                      ),
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
                          icon: edit
                              ? Icon(Icons.keyboard_arrow_down,
                                  color: Colors.grey)
                              : null,
                          iconSize: 32,
                          elevation: 4,
                          // style: IconStyle,
                          underline: Container(height: 0),
                          items: remindList
                              .map<DropdownMenuItem<String>>((int value) {
                            return DropdownMenuItem<String>(
                                value: value.toString(),
                                child: Text(value.toString()));
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
                        hint: "$_selectedRepeat ",
                        widget: DropdownButton(
                          icon: edit
                              ? Icon(Icons.keyboard_arrow_down,
                                  color: Colors.grey)
                              : null,
                          iconSize: 32,
                          elevation: 4,
                          // style: IconStyle,
                          underline: Container(height: 0),
                          items: repeatList
                              .map<DropdownMenuItem<String>>((String? value) {
                            return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value!,
                                  style: TextStyle(color: Colors.grey),
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
                      edit ? buttonAddNote() : Container(),
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
        enabled: edit,
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
        enabled: edit,
        style: TextStyle(color: Colors.white, fontSize: 17),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: _finishTime,
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
        onTap: () {
          _showDateTimeDialog();
        },
        controller: _controllerDateTime,
        enabled: edit,
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
        FirebaseFirestore.instance
            .collection("NoteTask")
            .doc(widget.id)
            .update({
          "title": _noteTitleController.text,
          "task": noteType,
          "Category": noteCategory,
          "decription": _noteDescriptionController.text,
          "DateFinish": _controllerDateTime.text,
          "TimeStart": _controllerTimeStart.text,
          "TimeFinish": _controllerTimeFinish.text,
          "FileNotes": fileNotes.toString(),
          "AudioNotes": audioNotes.toString(),
          "VideoNotes": videoNotes.toString(),
          "Remind": _selectedRemind,
          "Repeat": _selectedRepeat
        });
        setState(() {});
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Update note successfully')));
      },
      child: Container(
          height: 56,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  colors: [Color(0xff8a32f1), Color(0xffad32f9)])),
          child: Center(
            child: Text(
              "Update Note",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600),
            ),
          )),
    );
  }

  Widget taskType(String label, int color) {
    return InkWell(
      onTap: edit
          ? () {
              setState(() {
                noteType = label;
              });
            }
          : null,
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
      onTap: edit
          ? () {
              setState(() {
                noteCategory = label;
              });
            }
          : null,
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
        enabled: edit,
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
        enabled: edit,
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
