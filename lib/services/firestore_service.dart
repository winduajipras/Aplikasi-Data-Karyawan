import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jia/models/avatar_reference.dart';
import 'package:jia/models/user_apps_reference.dart';
import 'package:jia/services/firestore_path.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirestoreService({@required this.uid}) : assert(uid != null);
  final String uid;

  // Sets the avatar download url
  Future<void> setAvatarReference(AvatarReference avatarReference) async {
    final path = FirestorePath.avatar(uid);
    final reference = FirebaseFirestore.instance.doc(path);
    await reference.set(avatarReference.toMap());
  }

  // Reads the current avatar download url
  Stream<AvatarReference> avatarReferenceStream() {
    final path = FirestorePath.avatar(uid);
    final reference = FirebaseFirestore.instance.doc(path);
    final snapshots = reference.snapshots();
    return snapshots
        .map((snapshot) => AvatarReference.fromMap(snapshot.data()));
  }

  // Update data user apps
  Future<void> updateUserAppsReference(
      UserAppsReference userAppsReference, String selector) async {
    final path = FirestorePath.userApps(uid);
    final reference = FirebaseFirestore.instance.doc(path);
    //await reference.set(userAppsReference.toMap());
    if (selector == 'avatar')
      await reference.update(userAppsReference.toMapAvatarOnly());
    else if (selector == 'password')
      await reference.update(userAppsReference.toMapPasswordOnly());
  }

  // Reads data user apps
  Stream<UserAppsReference> userAppsReferenceStream() {
    final path = FirestorePath.userApps(uid);
    final reference = FirebaseFirestore.instance.doc(path);
    final snapshots = reference.snapshots();
    return snapshots
        .map((snapshot) => UserAppsReference.fromMap(snapshot.data()));
  }
}
