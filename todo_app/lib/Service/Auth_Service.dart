import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app/Page/HomePage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthClass {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final storage = new FlutterSecureStorage();

  Future<void> googleSignIn(BuildContext context) async {
    try {
      GoogleSignInAccount? googleSignInAccount = await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;
        AuthCredential credential = GoogleAuthProvider.credential(
            idToken: googleSignInAuthentication.idToken,
            accessToken: googleSignInAuthentication.accessToken);
        try {
          UserCredential userCredential =
              await firebaseAuth.signInWithCredential(credential);
          storeTokenAndData(userCredential);
          // 
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (builder) => HomePage()),
              (route) => false);
        } catch (e) {
          final snackBar = SnackBar(content: Text(e.toString()));
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } else {
        final snackBar = SnackBar(content: Text("Not able to sign in"));
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } catch (e) {
      final snackBar = SnackBar(content: Text(e.toString()));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  Future<void> storeTokenAndData(UserCredential userCredential) async {
    await storage.write(
        key: "token", value: userCredential.credential?.token.toString());
    await storage.write(
        key: "userCredential", value: userCredential.toString());
  }

  Future<String?> getToken() async {
    return await storage.read(key: "token");
  }

  Future<void> logOut() async {
    try {
      await _googleSignIn.signOut();
      await firebaseAuth.signOut();
      await storage.delete(key: "token");
    } catch (e) {
      print(e);
    }
  }

  Future<void> verifyPhoneNumber(
      String phoneNumber, BuildContext context, Function setData) async {
    PhoneVerificationCompleted verificationCompleted =
        (PhoneAuthCredential phoneAuthCredential) async {
      showSnackBar(context, "Verification compledted");
    };
    PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException exception) {
      showSnackBar(context, exception.toString());
    };
    PhoneCodeSent codeSent = (verificationId, [forceResendingToken]) {
      showSnackBar(context, "verification code sent on the phone number");
      setData(verificationId);
    };
    PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout = (verificationId) {
      showSnackBar(context, "Time Out");
    };

    try {
      await firebaseAuth.verifyPhoneNumber(
          phoneNumber: phoneNumber,
          verificationCompleted: verificationCompleted,
          verificationFailed: verificationFailed,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  void showSnackBar(BuildContext context, String text) {
    final snackBar = SnackBar(content: Text(text.toString()));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> SignInWithPhoneNumber(
      String verificationID, String smsCode, context) async {
    try {
      AuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationID, smsCode: smsCode);
      UserCredential userCredential =
          await firebaseAuth.signInWithCredential(credential);
      storeTokenAndData(userCredential);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => HomePage()),
          (route) => false);
      showSnackBar(context, "Logged in ");
    } catch (e) {
      showSnackBar(context, e.toString());
    }
  }

  Future ResetPasswordWithEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
    }
  }

  Future<void> resetPassword(String phoneNumber) async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+84 $phoneNumber",
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto verification of the code has been done, proceed with signing in
        await FirebaseAuth.instance.signInWithCredential(credential);
        // You can now change the password here
        await FirebaseAuth.instance.currentUser!.updatePassword('newPassword');
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle verification failure
      },
      codeSent: (String verificationId, int? resendToken) async {
        // Save the verification ID somewhere to retrieve it later
        String smsCode = ''; // This will be the OTP entered by the user
        // Create a PhoneAuthCredential with the verification code
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId,
          smsCode: smsCode,
        );
        // Sign in with the credential to complete verification
        await FirebaseAuth.instance.signInWithCredential(credential);
        // You can now change the password here
        await FirebaseAuth.instance.currentUser!.updatePassword('newPassword');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Called when the automatic code retrieval has timed out
      },
      timeout: const Duration(seconds: 60),
    );
  }
}
