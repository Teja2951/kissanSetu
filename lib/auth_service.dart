import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:kisaansetu/models/user_model.dart';

class AuthService {

  //final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<void> logInWithEmailAndPassword(
    {
      required String email,
      required String password,
      required BuildContext context,
    }
  ) async {
    try {
      final userCredentials = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredentials.user != null && !userCredentials.user!.emailVerified) {
        await userCredentials.user!.sendEmailVerification();
        showToast(
          "Email not verified. A new verification email has been sent.",
          context: context,
          animation: StyledToastAnimation.scale,
          position: StyledToastPosition.top,
          duration: const Duration(seconds: 10),
          backgroundColor: Colors.orange,
        );
        await FirebaseAuth.instance.signOut();
        return;
      }

      showToast(
        "Logged in Successfully",
        context: context,
        animation: StyledToastAnimation.scale,
        position: StyledToastPosition.bottom,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      );
    } catch (e) {
      showToast(
        e.toString(),
        context: context,
        animation: StyledToastAnimation.scale,
        position: StyledToastPosition.top,
        duration: const Duration(seconds: 10),
        backgroundColor: Colors.red,
      );
    }
  }


  Future<void> signUpWithEmailAndPassword(
    {
      required String email,
      required String password,
      required String name,
      required String role,
      required BuildContext context,

    }
  ) async {
    try {
      final userCredentials = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredentials.user?.sendEmailVerification();
      showToast('An Email has been sent to $email. Please verify.', context: context);
      print(userCredentials);

     UserModel newUser = UserModel(
      uid: userCredentials.user!.uid,
      email: email,
      name: name,
      role: [role], // Storing as a list
      createdAt: DateTime.now(),
      password: password,
    );

      await _firestore.collection('users').doc(userCredentials.user!.uid).set(newUser.toMap());
    } catch (e) {
      print(e);
      showToast(
        e.toString(),
        context: context,
        animation: StyledToastAnimation.scale,
        reverseAnimation: StyledToastAnimation.fade,
        position: StyledToastPosition.top,
        animDuration: const Duration(seconds: 1),
        duration: const Duration(seconds: 4),
        backgroundColor: Colors.red,
        curve: Curves.elasticOut,
        reverseCurve: Curves.linear,
      );
    }
  }

}