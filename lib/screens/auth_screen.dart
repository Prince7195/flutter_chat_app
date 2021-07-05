import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:chat_app/widgets/auth/auth_form.dart';
import 'package:flutter/services.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  var _isLoading = false;
  void _submitAuthForm(String email, String password, String username,
      bool isLogin, File image, BuildContext ctx) async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential;
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        final ref = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child(userCredential.user!.uid + '.jpg');
        await ref.putFile(image).then((_) {});
        final url = await ref.getDownloadURL();
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'username': username,
          'email': email,
          'image_url': url,
        });
      }
      print(userCredential.credential);
    } on PlatformException catch (err) {
      var message = 'An error occured, please check your credentials.';
      if (err.message != null) {
        message = err.message as String;
      }

      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    } on Exception catch (err) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(err.toString()),
        backgroundColor: Theme.of(context).errorColor,
      ));
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: AuthForm(_submitAuthForm, _isLoading),
    );
  }
}
