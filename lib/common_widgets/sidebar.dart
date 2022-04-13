import 'dart:async';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jia/app/data_master/absen_harian/master_absen_harian.dart';
import 'package:jia/app/data_master/data_karyawan/master_data_karyawan.dart';
import 'package:jia/app/data_master/lokasi.dart';
import 'package:jia/app/data_master/jabatan.dart';
import 'package:jia/app/data_master/data_struktur/struktur.dart';
import 'package:jia/app/generator/birthday.dart';
import 'package:jia/app/generator/meninggal.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:jia/common_widgets/avatar.dart';
import 'package:jia/models/user_apps_reference.dart';
import 'package:jia/services/firebase_storage_service.dart';
import 'package:jia/services/firestore_service.dart';
import 'package:jia/services/image_picker_service.dart';
import 'package:network_state/network_state.dart';
import 'package:provider/provider.dart';

class SideBar extends StatefulWidget {
  SideBar({this.page});
  final String page;
  @override
  _SideBarState createState() => _SideBarState();
}

class _SideBarState extends State<SideBar> {
  bool _isLoading = false;
  final sideBarTextColor = Colors.deepOrange;
  final bodyTextColor = Colors.deepOrange;
  final List<Color> _colors = [Colors.purple, Colors.deepOrange];

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

  _beranda(BuildContext context) {
    return InkWell(
      child: Padding(
        padding: const EdgeInsets.only(left: 15.0, bottom: 8.0, top: 20.0),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: new Icon(Icons.home, color: sideBarTextColor),
            ),
            new Text(
              "Beranda",
              style: new TextStyle(fontSize: 20.0, color: sideBarTextColor),
            ),
            new Expanded(
              child: SizedBox(),
            ),
            new Icon(Icons.chevron_right, color: sideBarTextColor),
            new SizedBox(
              width: 20.0,
            ),
          ],
        ),
      ),
      onTap: () {
        if (widget.page == 'beranda') {
          Navigator.of(context).pop(true);
        } else {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      },
    );
  }

  _dataMaster(BuildContext context, String role) {
    // bool addDisable = false;
    // if (role == 'admin') {
    //   addDisable = true;
    // }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, bottom: 8.0, top: 20.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: new Icon(Icons.folder_open, color: sideBarTextColor),
              ),
              new Text(
                "Data Master",
                style: new TextStyle(fontSize: 20.0, color: sideBarTextColor),
              ),
            ],
          ),
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 55.0),
                    child: new Text(
                      "Data Karyawan",
                      style: new TextStyle(
                          fontSize: 15.0, color: sideBarTextColor),
                    ),
                  ),
                  new Expanded(
                    child: SizedBox(),
                  ),
                  new Icon(Icons.chevron_right, color: sideBarTextColor),
                  new SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (widget.page == 'data karyawan') {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => DataKaryawan(),
                ),
              );
            }
          },
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 55.0),
                    child: new Text(
                      "Lokasi",
                      style: new TextStyle(
                          fontSize: 15.0, color: sideBarTextColor),
                    ),
                  ),
                  new Expanded(
                    child: SizedBox(),
                  ),
                  new Icon(Icons.chevron_right, color: sideBarTextColor),
                  new SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (widget.page == 'lokasi') {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => Lokasi(),
                ),
              );
            }
          },
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 55.0),
                    child: new Text(
                      "Jabatan",
                      style: new TextStyle(
                          fontSize: 15.0, color: sideBarTextColor),
                    ),
                  ),
                  new Expanded(
                    child: SizedBox(),
                  ),
                  new Icon(Icons.chevron_right, color: sideBarTextColor),
                  new SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (widget.page == 'jabatan') {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => Jabatan(),
                ),
              );
            }
          },
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 55.0),
                    child: new Text(
                      "Struktur",
                      style: new TextStyle(
                          fontSize: 15.0, color: sideBarTextColor),
                    ),
                  ),
                  new Expanded(
                    child: SizedBox(),
                  ),
                  new Icon(Icons.chevron_right, color: sideBarTextColor),
                  new SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (widget.page == 'struktur') {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => Struktur(),
                ),
              );
            }
          },
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 55.0),
                    child: new Text(
                      "Absensi Harian",
                      style: new TextStyle(
                          fontSize: 15.0, color: sideBarTextColor),
                    ),
                  ),
                  new Expanded(
                    child: SizedBox(),
                  ),
                  new Icon(Icons.chevron_right, color: sideBarTextColor),
                  new SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (widget.page == 'absensi harian') {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => AbsensiHarian(),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  _generator(BuildContext context, String role) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15.0, bottom: 8.0, top: 20.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: new Icon(Icons.folder_open, color: sideBarTextColor),
              ),
              new Text(
                "Generator",
                style: new TextStyle(fontSize: 20.0, color: sideBarTextColor),
              ),
            ],
          ),
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 55.0),
                    child: new Text(
                      "Ulang Tahun",
                      style: new TextStyle(
                          fontSize: 15.0, color: sideBarTextColor),
                    ),
                  ),
                  new Expanded(
                    child: SizedBox(),
                  ),
                  new Icon(Icons.chevron_right, color: sideBarTextColor),
                  new SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (widget.page == 'ulang tahun') {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => UlangTahun(),
                ),
              );
            }
          },
        ),
        InkWell(
          child: Padding(
            padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
            child: Container(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 55.0),
                    child: new Text(
                      "Berduka",
                      style: new TextStyle(
                          fontSize: 15.0, color: sideBarTextColor),
                    ),
                  ),
                  new Expanded(
                    child: SizedBox(),
                  ),
                  new Icon(Icons.chevron_right, color: sideBarTextColor),
                  new SizedBox(
                    width: 20.0,
                  ),
                ],
              ),
            ),
          ),
          onTap: () {
            if (widget.page == 'berduka') {
              Navigator.of(context).pop(true);
            } else {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (BuildContext context) => Meninggal(),
                ),
              );
            }
          },
        ),
      ],
    );
  }

  _setting(BuildContext context) {
    return Column(children: [
      InkWell(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, bottom: 8.0, top: 20.0),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: new Icon(Icons.settings, color: sideBarTextColor),
              ),
              new Text(
                "Setting",
                style: new TextStyle(fontSize: 20.0, color: sideBarTextColor),
              ),
              new Expanded(
                child: SizedBox(),
              ),
              new Icon(Icons.chevron_right, color: sideBarTextColor),
              new SizedBox(
                width: 20.0,
              ),
            ],
          ),
        ),
        onTap: () {
          if (widget.page == 'setting password') {
            Navigator.of(context).pop(true);
          } else {
            Navigator.of(context).popUntil((route) => route.isFirst);
            Navigator.of(context).push(
              new MaterialPageRoute(
                builder: (BuildContext context) => Container(),
              ),
            );
          }
        },
      ),
    ]);
  }

  _sideMenu(BuildContext context, String role) {
    if (role == 'dev') {
      return Column(
        children: [
          _beranda(context),
          _dataMaster(context, role),
          _setting(context),
        ],
      );
    } else if (role == 'mandor' || role == 'admin') {
      return Column(
        children: [
          _beranda(context),
          _dataMaster(context, role),
          _generator(context, role),
          _setting(context),
        ],
      );
    } else if (role == 'user') {
      return Column(
        children: [
          _beranda(context),
          _dataMaster(context, role),
          _generator(context, role),
          _setting(context),
        ],
      );
    } else if (role == 'manager') {
      return Column(
        children: [
          _beranda(context),
          _setting(context),
        ],
      );
    } else {
      return Column(
        children: [
          _beranda(context),
          _setting(context),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final database = Provider.of<FirestoreService>(context, listen: false);
    return StreamBuilder<UserAppsReference>(
        stream: database.userAppsReferenceStream(),
        builder: (context, snapshot) {
          final userAppsReference = snapshot.data;
          return Drawer(
            child: Container(
              color: Colors.white,
              child: new ListView(
                children: <Widget>[
                  UserAccountsDrawerHeader(
                    accountName: Text(
                      userAppsReference?.nama.toString(),
                      style: TextStyle(fontSize: 23.0),
                    ),
                    accountEmail: Text(userAppsReference?.email.toString()),
                    currentAccountPicture: _isLoading
                        ? CircularProgressIndicator(
                            backgroundColor: Colors.lightBlue,
                          )
                        : Avatar(
                            // photoUrl: userAppsReference?.avatarUrl,
                            photoUrl: null,
                            radius: 50,
                            borderColor: Colors.white,
                            borderWidth: 2.0,
                            onPressed: () async {
                              setState(() => _isLoading = true);
                              NetworkConfig.pingUrls = [
                                'http://mockbin.com/request'
                              ];
                              NetworkConfig.pollIntervalMs = 500;
                              NetworkConfig.timeoutMs = 2000;

                              NetworkState.startPolling();

                              final ns = new NetworkState();
                              bool key = false;
                              ns.addListener(() async {
                                final hasConnection =
                                    key ? false : await ns.isConnected;
                                if (hasConnection) {
                                  key = true;
                                  _chooseAvatar(context);
                                  NetworkState.stopPolling();
                                }
                                Future.delayed(Duration(seconds: 6), () {
                                  if (!key) {
                                    key = true;
                                    dialog(context,
                                            'Periksa sambungan internet Anda')
                                        .whenComplete(() =>
                                            setState(() => _isLoading = false));
                                    NetworkState.stopPolling();
                                  }
                                });
                              });
                            },
                          ),
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                      colors: _colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )),
                  ),
                  _sideMenu(context, userAppsReference?.role.toString()),
                ],
              ),
            ),
          );
        });
  }
}
