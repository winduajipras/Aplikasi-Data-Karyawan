import 'package:jia/app/auth_widget.dart';
import 'package:jia/app/auth_widget_builder.dart';
import 'package:jia/app/data_master/absen_harian/master_absen_harian.dart';
import 'package:jia/app/data_master/data_karyawan/public_master_data_karyawan.dart';
import 'package:jia/app/generator/bantuan.dart';
import 'package:jia/services/firebase_auth_service.dart';
import 'package:jia/services/image_picker_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // Initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // Check for errors
        if (snapshot.hasError) {
          return Container();
        }

        // Once complete, show your application
        if (snapshot.connectionState == ConnectionState.done) {
          return MultiProvider(
            providers: [
              Provider<FirebaseAuthService>(
                create: (_) => FirebaseAuthService(),
              ),
              Provider<ImagePickerService>(
                create: (_) => ImagePickerService(),
              ),
            ],
            child: AuthWidgetBuilder(builder: (context, userSnapshot) {
              return MaterialApp(
                  theme: ThemeData(primarySwatch: Colors.deepOrange),
                  //home: AuthWidget(userSnapshot: userSnapshot),
                  routes: {
                    '/': (context) => AuthWidget(userSnapshot: userSnapshot),
                    '/karyawan': (context) {
                      return DataKaryawan();
                    },
                    '/absensiharian': (context) {
                      return AbsensiHarian();
                    },
                    '/bantuan': (context) {
                      return Bantuan();
                    },
                  });
            }),
          );
        }
        // Otherwise, show something whilst waiting for initialization to complete
        return Container();
      },
    );
  }
}
