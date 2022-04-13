import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jia/app/generator/birthday.dart';
import 'package:jia/app/home/about_page.dart';
import 'package:jia/common_widgets/sidebar.dart';
import 'package:jia/models/user_apps_reference.dart';
import 'package:jia/services/firebase_auth_service.dart';
import 'package:jia/services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final List<Color> _colors = [Colors.purple[300], Colors.deepOrange[300]];
  int touchedIndex;
  bool trial = false;
  DateTime now = DateTime.now();

  _getBirthDay(DateTime now) {
    return now.day.toString() + '-' + now.month.toString();
  }

  _selectDates(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: now, // Refer step 1
      firstDate: DateTime(2015),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != now) {
      setState(() {
        now = picked;
      });
    }
  }

  Future<void> _signOut(BuildContext context) async {
    try {
      final auth = Provider.of<FirebaseAuthService>(context, listen: false);
      await auth.signOut();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _onAbout(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => AboutPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideBar(
        page: 'beranda',
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Home'),
        leading: IconButton(
          icon: Icon(Icons.help),
          onPressed: () => _onAbout(context),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: Text(
              'Logout',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.white,
              ),
            ),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      bottomNavigationBar: new BottomAppBar(
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
        color: Colors.deepOrange,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              icon: Icon(
                Icons.menu,
                color: Colors.white,
              ),
              onPressed: () => _scaffoldKey.currentState.openDrawer(),
            ),
            new Expanded(child: new SizedBox()),
            IconButton(
              icon: Icon(
                Icons.calendar_today,
                color: Colors.white,
              ),
              onPressed: () => _selectDates(context),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 3.0,
              child: Center(
                child: _userApps(context: context),
              ),
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(trial ? 'trialuser' : 'user')
                  .where('tglLahirShort', isEqualTo: _getBirthDay(now))
                  .where('aktif', isEqualTo: 'Masih Bekerja')
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else {
                  if (snapshot.data.docs.length == 0) {
                    return Container();
                  } else {
                    return Container(
                      child: ListView.builder(
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        itemCount: snapshot.data.docs.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            elevation: 8.0,
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _colors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 8.0),
                                leading: Container(
                                  padding: EdgeInsets.only(right: 12.0),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: BorderSide(
                                              width: 1.0,
                                              color: Colors.white24))),
                                  child: Icon(Icons.cake_rounded,
                                      color: Colors.white),
                                ),
                                title: Text(
                                  snapshot.data.docs[index].get('nama'),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                subtitle: Row(
                                  children: [
                                    Icon(Icons.linear_scale,
                                        color: Colors.yellowAccent),
                                    Text(
                                        " " +
                                            snapshot.data.docs[index]
                                                .get('bagian') +
                                            ' - ' +
                                            snapshot.data.docs[index]
                                                .get('lokasi'),
                                        style: TextStyle(color: Colors.white)),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.keyboard_arrow_right),
                                  color: Colors.white,
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      new MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            UlangTahun(
                                          nama: snapshot.data.docs[index]
                                              .get('nama'),
                                          tglLahir: snapshot.data.docs[index]
                                              .get('tglLahir'),
                                          jabatan: snapshot.data.docs[index]
                                              .get('bagian'),
                                          lokasi: snapshot.data.docs[index]
                                              .get('lokasi'),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _userApps({BuildContext context}) {
    final database = Provider.of<FirestoreService>(context, listen: false);
    return StreamBuilder<UserAppsReference>(
      stream: database.userAppsReferenceStream(),
      builder: (context, snapshot) {
        final userAppsReference = snapshot.data;
        return Text(
          'Selamat datang ${userAppsReference?.nama.toString()}',
          style: TextStyle(fontSize: 18.0),
        );
      },
    );
  }
}
