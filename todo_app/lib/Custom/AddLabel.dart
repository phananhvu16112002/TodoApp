import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class AddLabel extends StatefulWidget {
  const AddLabel({Key? key}) : super(key: key);

  @override
  State<AddLabel> createState() => _AddLabelState();
}

class _AddLabelState extends State<AddLabel> {
  final TextEditingController _labelController = TextEditingController();
  late List<String> _labels;

  @override
  void initState() {
    super.initState();
    _labels = [];
    _loadLabels();
  }

  void _loadLabels() async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .where('userID', isEqualTo: userID);

    final snapshot = await userRef.get();

    if (snapshot.size > 0) {
      final data = snapshot.docs[0].data() as Map<String, dynamic>;
      setState(() {
        _labels = List<String>.from(data['labels'] ?? []);
      });
    }
  }

  void _addLabel() async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .where('userID', isEqualTo: userID);

    if (_labels.length < 3 && _labelController.text.isNotEmpty) {
      setState(() {
        _labels.add(_labelController.text);
      });

      // lấy document đầu tiên trả về bởi query, vì query trả về danh sách document
      final snapshot = await userRef.get();
      if (snapshot.docs.isNotEmpty) {
        final document = snapshot.docs.first;
        await document.reference.update({'labels': _labels});
      }

      _labelController.clear();
    }
  }

  void _removeLabel(int index) async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .where('userID', isEqualTo: userID);

    setState(() {
      _labels.removeAt(index);
    });

    await userRef.get().then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        doc.reference.update({'labels': _labels});
      });
    });
  }

  void _editLabel(int index) async {
    final userID = FirebaseAuth.instance.currentUser?.uid;
    final userRef = FirebaseFirestore.instance
        .collection('users')
        .where('userID', isEqualTo: userID);

    final result = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _textEditingController =
            TextEditingController(text: _labels[index]);
        return AlertDialog(
          title: const Text('Edit Label'),
          content: TextField(
            controller: _textEditingController,
            decoration: const InputDecoration(
              labelText: 'Label name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.pop(context, _textEditingController.text);
              },
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      setState(() {
        _labels[index] = result;
      });

      final snapshot = await userRef.get();
      if (snapshot.docs.isNotEmpty) {
        final document = snapshot.docs.first;
        await document.reference.update({'labels': _labels});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Label'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(
                labelText: 'Label name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              child: const Text('Add Label'),
              onPressed: _addLabel,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _labels.length,
                itemBuilder: (context, index) {
                  return Slidable(
                    key: const ValueKey(0),
                    endActionPane:
                        ActionPane(motion: const ScrollMotion(), children: [
                      SlidableAction(
                        onPressed: (context) => _removeLabel(index),
                        backgroundColor: Color(0xFFFE4A49),
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                      SlidableAction(
                        onPressed: (context) => _editLabel(index),
                        backgroundColor: Color(0xFF1F9D3A),
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                        label: 'Edit',
                      ),
                    ]),
                    child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      color: Colors.blue,
                      child: ListTile(
                        title: Text(_labels[index]),
                        // trailing: Row(
                        //   mainAxisSize: MainAxisSize.min,
                        //   children: [
                        //     // IconButton(
                        //     //   icon: const Icon(Icons.edit),
                        //     //   onPressed: () => _editLabel(index),
                        //     // ),
                        //     // IconButton(
                        //     //   icon: const Icon(Icons.delete),
                        //     //   onPressed: () => _removeLabel(index),
                        //     // ),
                        //   ],
                        // ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
