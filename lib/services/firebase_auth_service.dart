import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

@immutable
class User {
  const User({@required this.uid});
  final String uid;
}

class FirebaseAuthService {
  final _firebaseAuth = auth.FirebaseAuth.instance;

  User _userFromFirebase(auth.User user) {
    return user == null ? null : User(uid: user.uid);
  }

  Stream<User> get onAuthStateChanged {
    return _firebaseAuth.authStateChanges().map(_userFromFirebase);
  }

  Future<User> signInWithEmailAndPassword(String email, String password) async {
    final authResult = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    print('Singed in: ${authResult.user.uid}');
    return _userFromFirebase(authResult.user);
  }

  Future<User> createUserWithEmailAndPassword(BuildContext context,
      String email, String password, String name, int id, String role) async {
    final authResult = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    print('Registerd in: ${authResult.user.uid}');
    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      final reference =
          FirebaseFirestore.instance.doc('userApps/${authResult.user.uid}');
      await reference.set({
        'nama': name,
        'id': id,
        'email': email,
        'password': password,
        'role': role,
        'avatarUrl':
            'https://firebasestorage.googleapis.com/v0/b/pt-lima-satu-lima.appspot.com/o/userApps%2Fdefault.jpg?alt=media&token=7ae63fc8-16f6-46a1-b92b-6d14b3751c1b',
      });
    });

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, color: Colors.orange),
              Text(' Peringatan '),
              Icon(Icons.warning, color: Colors.orange),
            ],
          ),
          content: new Text('Pembuatan akun sukses, mohon login ulang',
              textAlign: TextAlign.center),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Ok'),
              onPressed: () async {
                Navigator.pop(context);
                await _firebaseAuth.signOut();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> signOut() async {
    return await _firebaseAuth.signOut();
  }
}
