import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:network_state/network_state.dart';

class EditStruktur extends StatefulWidget {
  final String nama;
  final String jabatan;
  final DocumentReference ref;
  final QuerySnapshot parentSnapshot;
  EditStruktur({this.nama, this.jabatan, this.ref, this.parentSnapshot});
  @override
  _EditStrukturState createState() => _EditStrukturState();
}

class _EditStrukturState extends State<EditStruktur> {
  String _nama = '';
  String _jabatan = '';
  bool _isLoading = false;

  TextEditingController controllerNama;
  TextEditingController controllerJabatan;

  void updateData() {
    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.ref);
      transaction.update(snapshot.reference, {
        'nama': _nama,
        'jabatan': _jabatan,
      });
    }).whenComplete(() {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      widget.parentSnapshot.docs.forEach((element) {
        batch.set(
          element.reference,
          {'parent': _jabatan + '\\n\\n' + _nama},
          SetOptions(merge: true),
        );
      });
      batch.commit().then((value) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context, widget.jabatan + '\n\n' + widget.nama);
      }).catchError((err) {});
    });
  }

  @override
  void initState() {
    super.initState();
    _nama = widget.nama;
    _jabatan = widget.jabatan;
    controllerNama = TextEditingController(text: widget.nama);
    controllerJabatan = TextEditingController(text: widget.jabatan);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _isLoading
          ? CircularProgressIndicator()
          : FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.check),
              onPressed: () async {
                setState(() {
                  _isLoading = true;
                });
                NetworkConfig.pingUrls = ['https://mockbin.com/request'];
                NetworkConfig.pollIntervalMs = 500;
                NetworkConfig.timeoutMs = 2000;

                NetworkState.startPolling();

                final ns = new NetworkState();
                bool key = false;
                ns.addListener(() async {
                  final hasConnection = key ? false : await ns.isConnected;
                  if (hasConnection) {
                    key = true;
                    updateData();
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
              },
            ),
      bottomNavigationBar: new BottomAppBar(
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
        color: Colors.deepOrange,
        child: new Row(mainAxisSize: MainAxisSize.max, children: <Widget>[
          new Expanded(child: new SizedBox()),
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context, '##');
            },
          ),
        ]),
      ),
      appBar: new AppBar(
        title: new Text('Tambah Data Struktur'),
      ),
      body: new Container(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              children: [
                TextField(
                  controller: controllerNama,
                  onChanged: (String str) {
                    _nama = str;
                  },
                  decoration: new InputDecoration(
                    icon: Icon(Icons.person),
                    labelText: 'Nama',
                    border: InputBorder.none,
                  ),
                ),
                TextField(
                  controller: controllerJabatan,
                  onChanged: (String str) {
                    _jabatan = str;
                  },
                  decoration: new InputDecoration(
                    icon: Icon(Icons.label),
                    labelText: 'Jabatan',
                    border: InputBorder.none,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
