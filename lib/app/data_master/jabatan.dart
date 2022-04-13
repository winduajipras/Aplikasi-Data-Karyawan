import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:jia/common_widgets/sidebar.dart';
import 'package:network_state/network_state.dart';

class Jabatan extends StatefulWidget {
  @override
  _JabatanState createState() => _JabatanState();
}

class _JabatanState extends State<Jabatan> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final List<Color> _colors = [Colors.purple[300], Colors.deepOrange[300]];
  bool trial = false;
  String _jabatan = '';
  String _tmpJabatan = '';
  bool _isLoading = false;

  void addData() {
    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = FirebaseFirestore.instance
          .collection(trial ? 'trialjabatan' : 'jabatan');
      await reference.add({
        'jabatan': _jabatan,
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
    });
  }

  List<Widget> _buildRows(List<DocumentSnapshot> document) {
    return List.generate(
      document.length,
      (index) => Card(
        elevation: 8.0,
        margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            contentPadding:
                EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            leading: Container(
              padding: EdgeInsets.only(right: 12.0),
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(width: 1.0, color: Colors.white24))),
              child: Icon(Icons.location_on, color: Colors.white),
            ),
            title: Text(
              document[index].get('jabatan'),
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            trailing: _isLoading
                ? CircularProgressIndicator()
                : IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String alertText =
                              "Apakah anda yakin menghapus data jabatan\n" +
                                  document[index].get('jabatan') +
                                  "";

                          return AlertDialog(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.warning, color: Colors.orange),
                                Text(' Peringatan '),
                                Icon(Icons.warning, color: Colors.orange),
                              ],
                            ),
                            content: Text(alertText),
                            actions: <Widget>[
                              ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    NetworkConfig.pingUrls = [
                                      'https://mockbin.com/request'
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
                                        Navigator.of(context).pop(true);
                                        DocumentReference reference =
                                            document[index].reference;
                                        FirebaseFirestore.instance
                                            .runTransaction(
                                                (transaction) async {
                                          DocumentSnapshot snapshot =
                                              await transaction.get(reference);
                                          transaction
                                              .delete(snapshot.reference);
                                        });
                                        Future.delayed(
                                            Duration(milliseconds: 500), () {
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        });
                                        NetworkState.stopPolling();
                                      }
                                      Future.delayed(Duration(seconds: 6), () {
                                        if (!key) {
                                          key = true;
                                          dialog(context,
                                                  'Periksa sambungan internet Anda')
                                              .whenComplete(() => setState(
                                                  () => _isLoading = false));
                                          NetworkState.stopPolling();
                                        }
                                      });
                                    });
                                  },
                                  child: const Text("Ya")),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text("Tidak"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: SideBar(
        page: 'jabatan',
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
          ],
        ),
      ),
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: new Text('Jabatan'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20.0),
                width: MediaQuery.of(context).size.width * 0.65,
                child: TextField(
                  onChanged: (String str) {
                    _tmpJabatan = str;
                  },
                  decoration: InputDecoration(
                    labelText: 'Tambah Nama Jabatan',
                    suffixIcon: _isLoading
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: Icon(Icons.exit_to_app_rounded),
                            onPressed: () {
                              setState(() {
                                _jabatan = _tmpJabatan.toUpperCase();
                                _isLoading = true;
                              });
                              NetworkConfig.pingUrls = [
                                'https://mockbin.com/request'
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
                                  addData();
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
                  ),
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection(trial ? 'trialjabatan' : 'jabatan')
                    .orderBy('jabatan', descending: false)
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
                      return Column(
                        children: _buildRows(snapshot.data.docs),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
