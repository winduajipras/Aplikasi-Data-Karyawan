import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:network_state/network_state.dart';

class AddStruktur extends StatefulWidget {
  final String parent;
  AddStruktur({this.parent});
  @override
  _AddStrukturState createState() => _AddStrukturState();
}

class _AddStrukturState extends State<AddStruktur> {
  String _nama = '';
  String _jabatan = '';
  String _parent = '';
  bool _isLoading = false;

  void addData() {
    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference =
          FirebaseFirestore.instance.collection('struktur');
      await reference.add({
        'nama': _nama,
        'jabatan': _jabatan,
        'parent': _parent,
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    });
  }

  @override
  void initState() {
    super.initState();
    _parent = widget.parent;
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
                    addData();
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
              Navigator.pop(context);
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
