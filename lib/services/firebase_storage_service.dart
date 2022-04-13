import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:jia/services/firestore_path.dart';
import 'package:flutter/foundation.dart';

class FirebaseStorageService {
  FirebaseStorageService({@required this.uid}) : assert(uid != null);
  final String uid;

  /// Upload an avatar from file
  Future<String> uploadAvatar({
    @required File file,
  }) async =>
      await upload(
        file: file,
        path: FirestorePath.userApps(uid) + '/avatar.png',
        contentType: 'image/png',
      );

  Future<String> adminUploadAvatar({@required File file, String path}) async =>
      await upload(
        file: file,
        path: path + '/avatar.png',
        contentType: 'image/png',
      );

  /// Generic file upload for any [path] and [contentType]
  Future<String> upload({
    @required File file,
    @required String path,
    @required String contentType,
  }) async {
    print('uploading to: $path');
    final storageReference = FirebaseStorage.instance.ref().child(path);
    final uploadTask = storageReference.putFile(
        file, SettableMetadata(contentType: contentType));
    final snapshot = await uploadTask.catchError((e) {
      print('upload error code: $e');
    });

    // Url used to download file/image
    final downloadUrl = await snapshot.ref.getDownloadURL();
    print('downloadUrl: $downloadUrl');
    return downloadUrl;
  }
}
