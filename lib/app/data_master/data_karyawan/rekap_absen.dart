import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:network_state/network_state.dart';

class RekapAbsen extends StatefulWidget {
  final List<DocumentSnapshot> query;
  final DateTime rangeKehadiran;
  final DateTime rangeKehadiran1;
  RekapAbsen({this.query, this.rangeKehadiran, this.rangeKehadiran1});
  @override
  _RekapAbsenState createState() => _RekapAbsenState();
}

class _RekapAbsenState extends State<RekapAbsen> {
  String _nama = '';
  bool _isLoading = false;
  bool _kirim = false;
  int indexRow = 0;
  List<Map<String, dynamic>> _data = [];
  List<Map<String, dynamic>> _listRekap = [];
  List<Map<String, dynamic>> _tmpListRekap = [];
  // List<Map<String, dynamic>> _tmpAddListRecap = [];
  List<Map<String, dynamic>> _tmpAddListRecapNama = [];

  List<String> headerTabel = [
    'Nama Db',
    'Nama',
    'S',
    'ITD',
    'IDP',
    'CT',
    'OT',
  ];

  List<double> columnSize = [170, 170, 70, 70, 70, 70, 70];

  void addData() {
    //new data
    // _tmpAddListRecap = [];
    // _tmpAddListRecapNama.forEach((element) {
    //   _data.forEach((elements) {
    //     if (element['nama'] == elements['Nama']) {
    //       _tmpAddListRecap.add({
    //         'nama': element['nama'],
    //         'listRekap': {
    //           'tanggal': element['tanggal'],
    //           'S': elements['S'],
    //           'ITD': elements['ITD'],
    //           'IDP': elements['IDP'],
    //           'CT': elements['CT'],
    //           'OT': elements['OT']
    //         }
    //       });
    //     }
    //   });
    // });
    print(_listRekap);

    print('===================');
    _listRekap.forEach((element) {
      // element['listRekap'].forEach((i) {
      //   i.removeWhere((del) => del.startWith(123));
      // });
    });

    // _tmpListRekap.forEach((element) {
    //   _listRekap.forEach((elements) {
    //     if (element['nama'] == elements['nama']) {
    //       print(element['nama'] +
    //           ' - ' +
    //           _getFormatedDate(element['listRekap']['tanggal']));
    //       // element['listRekap'].forEach((tgl) {
    //       // print(element);
    //       //     bool contain = false;
    //       //     elements['listRekap'].forEach((tgls) {
    //       //       if (tgl['tanggal'] == tgls['tanggal']) {
    //       //         contain = true;
    //       //       }
    //       //     });
    //       //     if (!contain) {
    //       //       _tmpAddListRecap.add(element);
    //       //     }
    //       // });
    //     }
    //   });
    // });
    // WriteBatch batch = FirebaseFirestore.instance.batch();
    // _data.forEach((element) {
    //   batch.set(
    //     element['Ref'],
    //     {
    //       'listRekap': [
    //         {
    //           's': element['S'],
    //           'itd': element['ITD'],
    //           'idp': element['IDP'],
    //           'ct': element['CT'],
    //           'ot': element['OT'],
    //           'tanggal': widget.rangeKehadiran,
    //         }
    //       ]
    //     },
    //     SetOptions(merge: true),
    //   );
    // });
    // batch.commit().then((value) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   Navigator.pop(context);
    // }).catchError((err) {});
  }

  /*
  _getFormatedDate(timestamp) {
    if (timestamp == null) return '';
    var date = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    String year = date.year.toString();
    List<String> month = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    String day = date.day.toString();
    return day + ' ' + month[date.month - 1] + ' ' + year;
  }
  */

  List<Widget> _buildCells(int row, List<Map<String, dynamic>> _data) {
    return List.generate(
      headerTabel.length,
      (index) => Container(
        alignment: Alignment.centerLeft,
        width: columnSize[index],
        height: 40.0,
        margin: EdgeInsets.only(left: 2.0, top: 5.0),
        child: row == 0
            ? Text(headerTabel[index],
                style: new TextStyle(
                    fontSize: 17.0,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold))
            : index == 0
                ? widget.query != null
                    ? Text(widget.query[row - 1].get('nama'))
                    : Text('')
                : Text(
                    index == 1
                        ? _data[row - 1][headerTabel[index]]
                        : _data[row - 1][headerTabel[index]].toString(),
                    style: new TextStyle(
                      color: _data[row - 1]['Ref'] == null
                          ? Colors.deepOrange
                          : Colors.black,
                    ),
                  ),
      ),
    );
  }

  List<Widget> _buildRows(List<Map<String, dynamic>> _data) {
    return List.generate(
      _data.length + 1,
      (index) => Row(
        children: _buildCells(index, _data),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.query != null) {
      _tmpAddListRecapNama = [];
      widget.query.forEach((element) {
        if (element.get('totalRekap') != null) {
          _listRekap.add({
            'nama': element.get('nama'),
            'listRekap': element.get('totalRekap')
          });
          bool contain = false;
          for (var tgl in element.get('totalRekap')) {
            if (tgl['tanggal'].seconds >=
                    Timestamp.fromDate(
                      widget.rangeKehadiran.subtract(
                        Duration(
                            hours: widget.rangeKehadiran.hour,
                            minutes: widget.rangeKehadiran.minute,
                            seconds: widget.rangeKehadiran.second),
                      ),
                    ).seconds &&
                tgl['tanggal'].seconds <=
                    Timestamp.fromDate(
                      widget.rangeKehadiran1.add(
                        Duration(
                            hours: 23 - widget.rangeKehadiran1.hour,
                            minutes: 59 - widget.rangeKehadiran1.minute,
                            seconds: 59 - widget.rangeKehadiran1.second),
                      ),
                    ).seconds) {
              _tmpListRekap
                  .add({'nama': element.get('nama'), 'listRekap': tgl});
              contain = true;
            }
          }
          if (!contain) {
            _tmpAddListRecapNama.add({
              'nama': element.get('nama'),
              'tanggal': Timestamp.fromDate(widget.rangeKehadiran)
            });
          }
        }
      });
    }
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
                if (_kirim) {
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
                } else {
                  dialog(context, 'Periksa kembali, Data belum cocok');
                }
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
              print(_listRekap);
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
                    List<String> nama = [];
                    List<double> s = [];
                    List<double> itd = [];
                    List<double> idp = [];
                    List<double> ct = [];
                    List<double> ot = [];
                    _data = [];
                    _kirim = true;

                    for (var i = 0; i < _nama.split('\t').length; i++) {
                      double val;
                      if (i % 7 == 3 ||
                          i % 7 == 4 ||
                          i % 7 == 5 ||
                          i % 7 == 6) {
                        val = double.parse(_nama.split('\t')[i].contains(',')
                            ? _nama.split('\t')[i].replaceAll(',', '.')
                            : _nama
                                .split('\t')[i]
                                .replaceAll(RegExp(r'\s|-'), '0'));
                      } else if (i % 7 == 0 && i != 0) {
                        String dat = _nama.split('\t')[i].split(' ')[1];
                        val = double.parse(dat.contains(',')
                            ? dat.replaceAll(',', '.')
                            : dat.replaceAll(RegExp(r'\s|-'), '0'));
                      }
                      if (i % 7 == 1) {
                        nama.add(_nama.split('\t')[i]);
                      } else if (i % 7 == 3) {
                        s.add(val);
                      } else if (i % 7 == 4) {
                        itd.add(val);
                      } else if (i % 7 == 5) {
                        idp.add(val);
                      } else if (i % 7 == 6) {
                        ct.add(val);
                      } else if (i % 7 == 0 && i != 0) {
                        ot.add(val);
                      }
                    }
                    for (var j = 0; j < nama.length; j++) {
                      DocumentReference ref;
                      if (widget.query != null) {
                        for (var k in widget.query) {
                          if (k.get('nama').contains(nama[j])) {
                            ref = k.reference;
                          }
                        }
                      }
                      if (ref == null) {
                        _kirim = false;
                      }
                      _data.add({
                        'Nama': nama[j],
                        'S': s[j],
                        'ITD': itd[j],
                        'IDP': idp[j],
                        'CT': ct[j],
                        'OT': ot[j],
                        'Ref': ref,
                      });
                    }
                    _data.sort((a, b) => a['Nama'].compareTo(b['Nama']));
                    setState(() {});
                  },
                  decoration: new InputDecoration(
                    icon: Icon(Icons.paste),
                    labelText: 'Masukkan Data',
                    border: InputBorder.none,
                  ),
                ),
                _nama != ''
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Container(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: _buildRows(_data),
                            ),
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
