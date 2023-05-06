import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<DocumentSnapshot> getUser(String userID) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(userID)
        .get();
  }

  static Future<void> addUserDetails(String firstName, String lastName,
      String email, String phoneNumber, String userID) async {
    await _db.collection('users').add({
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'sizeText': '',
      'soundNotification': '',
      'labels': [],
      'userID': userID
    });
  }
}
