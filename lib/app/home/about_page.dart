import 'dart:async';

import 'package:image_picker/image_picker.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:jia/common_widgets/avatar.dart';
import 'package:jia/models/user_apps_reference.dart';
import 'package:jia/services/firebase_storage_service.dart';
import 'package:jia/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:jia/services/image_picker_service.dart';
import 'package:network_state/network_state.dart';
import 'package:provider/provider.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  bool _isLoading = false;

  Future<void> _chooseAvatar(BuildContext context) async {
    try {
      // 1. Get image from picker
      final imagePicker =
          Provider.of<ImagePickerService>(context, listen: false);
      final file = await imagePicker
          .pickImage(source: ImageSource.gallery)
          .whenComplete(() => setState(() => _isLoading = false));
      if (file != null) {
        setState(() => _isLoading = true);
        // 2. Upload to storage
        final storage =
            Provider.of<FirebaseStorageService>(context, listen: false);
        final downloadUrl = await storage.uploadAvatar(file: file);
        // 3. Save url to Firestore
        final database = Provider.of<FirestoreService>(context, listen: false);
        await database
            .updateUserAppsReference(
                UserAppsReference(null, null, null, null, null, downloadUrl),
                'avatar')
            .whenComplete(() => setState(() => _isLoading = false));
        // 4. (optional) delete local file as no longer needed
        await file.delete();
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(130.0),
          child: Column(
            children: <Widget>[
              _buildUserInfo(context: context),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Jatinom Indah Agri Apps',

              //import data to database todo
              style: Theme.of(context).textTheme.headline5,
            ),
            SizedBox(height: 32),
            Text(
              'Version: 1.5.1',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(height: 32),
            Text(
              'winduajiprasetiyo95@gmail.com',
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo({BuildContext context}) {
    final database = Provider.of<FirestoreService>(context, listen: false);
    return StreamBuilder<UserAppsReference>(
      stream: database.userAppsReferenceStream(),
      builder: (context, snapshot) {
        final avatarReference = snapshot.data;
        return _isLoading
            ? Padding(
                padding: const EdgeInsets.only(bottom: 30.0),
                child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlue,
                ),
              )
            : Avatar(
                photoUrl: avatarReference?.avatarUrl,
                radius: 50,
                borderColor: Colors.white,
                borderWidth: 2.0,
                onPressed: () async {
                  setState(() => _isLoading = true);
                  _chooseAvatar(context);
                  NetworkConfig.pingUrls = ['http://mockbin.com/request'];
                  NetworkConfig.pollIntervalMs = 500;
                  NetworkConfig.timeoutMs = 2000;

                  NetworkState.startPolling();

                  final ns = new NetworkState();
                  bool key = false;
                  ns.addListener(() async {
                    final hasConnection = key ? false : await ns.isConnected;
                    if (hasConnection) {
                      key = true;
                      _chooseAvatar(context);
                      NetworkState.stopPolling();
                    }
                    Future.delayed(Duration(seconds: 6), () {
                      if (!key) {
                        key = true;
                        dialog(context, 'Periksa sambungan internet Anda')
                            .whenComplete(
                                () => setState(() => _isLoading = false));
                        NetworkState.stopPolling();
                      }
                    });
                  });
                  // try {
                  //   final result = await InternetAddress.lookup('google.com')
                  //       .timeout(Duration(seconds: 6));
                  //   if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                  //     _chooseAvatar(context);
                  //   }
                  // } on SocketException catch (_) {
                  //   dialog(context, 'Periksa sambungan internet Anda')
                  //       .whenComplete(() => setState(() => _isLoading = false));
                  // } on TimeoutException catch (_) {
                  //   dialog(context, 'Periksa sambungan internet Anda')
                  //       .whenComplete(() => setState(() => _isLoading = false));
                  // }
                });
      },
    );
  }
}
