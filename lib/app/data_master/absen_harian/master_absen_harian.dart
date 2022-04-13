import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:jia/app/data_master/absen_harian/add_absen_harian.dart';
import 'package:jia/common_widgets/sidebar.dart';

class AbsensiHarian extends StatefulWidget {
  final String nama;
  AbsensiHarian({this.nama});
  @override
  _AbsensiHarianState createState() => _AbsensiHarianState();
}

class _AbsensiHarianState extends State<AbsensiHarian> {
  bool trial = true;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _tmpDrop = 'Pilih Lokasi';
  List _listLokasi = ['Pilih Lokasi'];
  DateTime _tglAbsenHarian = DateTime.now();
  DateTime now = DateTime.now();
  DateTime now1 = DateTime.now();
  bool editButton = false;

  List<DocumentSnapshot> query = [];
  bool _isLoading = false;
  bool _descending = false;
  String sort = 'nama';

  List<double> columnSize = [
    130.0,
    140.0,
    110.0,
    140.0,
    150.0,
    110.0,
    130.0,
    140.0,
    110.0,
    140.0,
    150.0,
    110.0,
    130.0,
    140.0,
    110.0,
    130.0,
    140.0,
    110.0,
    130.0,
    140.0,
    110.0,
    150.0,
    150.0,
    150.0,
    150.0,
    150.0,
  ];

  List dataGet = [
    'sabtu',
    'sabtu',
    'sabtu',
    'minggu',
    'minggu',
    'minggu',
    'senin',
    'senin',
    'senin',
    'selasa',
    'selasa',
    'selasa',
    'rabu',
    'rabu',
    'rabu',
    'kamis',
    'kamis',
    'kamis',
    'jumat',
    'jumat',
    'jumat',
    '',
    'gajiperhari',
    '',
    'fullday',
    '',
  ];

  List headerTabel = [
    'Sabtu Pagi',
    'Sabtu Siang',
    'Lembur',
    'Minggu Pagi',
    'Minggu Siang',
    'Lembur',
    'Senin Pagi',
    'Senin Siang',
    'Lembur',
    'Selasa Pagi',
    'Selasa Siang',
    'Lembur',
    'Rabu Pagi',
    'Rabu Siang',
    'Lembur',
    'Kamis Pagi',
    'Kamis Siang',
    'Lembur',
    'Jumat Pagi',
    'Jumat Siang',
    'Lembur',
    'Jml Hari',
    'Rp/hari',
    'Lembur',
    'Full Day',
    'Total Gaji',
  ];

  _selectDates(
      BuildContext context, DateTime tgl, int fyear, int lyear, int i) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: tgl, // Refer step 1
      firstDate: DateTime(fyear),
      lastDate: DateTime(lyear),
    );
    if (picked != null && picked != now) {
      setState(() {
        if (i == 0)
          now = picked;
        else if (i == 1)
          now1 = picked;
        else if (i == 2) _tglAbsenHarian = picked;
      });
    }
  }

  _getStartorEndWeek(DateTime current, String batas) {
    int substract;
    int add;
    DateTime batasBawah;
    DateTime batasAtas;

    if (batas == 'bawah') {
      if (current.weekday == 1)
        substract = 2;
      else if (current.weekday == 2)
        substract = 3;
      else if (current.weekday == 3)
        substract = 4;
      else if (current.weekday == 4)
        substract = 5;
      else if (current.weekday == 5)
        substract = 6;
      else if (current.weekday == 6)
        substract = 0;
      else if (current.weekday == 7) substract = 1;

      batasBawah = current.subtract(Duration(
          days: substract,
          hours: current.hour,
          minutes: current.minute,
          seconds: current.second));
      return Timestamp.fromDate(batasBawah);
    } else if (batas == 'atas') {
      if (current.weekday == 1)
        add = 4;
      else if (current.weekday == 2)
        add = 3;
      else if (current.weekday == 3)
        add = 2;
      else if (current.weekday == 4)
        add = 1;
      else if (current.weekday == 5)
        add = 0;
      else if (current.weekday == 6)
        add = 6;
      else if (current.weekday == 7) add = 5;

      batasAtas = current.add(Duration(
          days: add,
          hours: 23 - current.hour,
          minutes: 59 - current.minute,
          seconds: 59 - current.second));
      return Timestamp.fromDate(batasAtas);
    }
  }

  _calculateJmlHaridanLembur(Map jamKerja, String mode) {
    double hari = 0;
    double jam = 0;
    double total = 0;
    int finalHari = 0;
    double jamLembur = 0;
    double finalLembur = 0;
    String hasil = '';
    jamKerja.forEach((key, value) {
      if (key == 'senin' ||
          key == 'selasa' ||
          key == 'rabu' ||
          key == 'kamis' ||
          key == 'jumat' ||
          key == 'sabtu' ||
          key == 'minggu') {
        hari += value[0] + value[1];
        if (value[2] <= 1) {
          jamLembur = value[2] * 1.5;
          finalLembur += jamLembur * (3 / 20) * jamKerja['gajiperhari'];
        } else if (value[2] <= 8) {
          jamLembur = value[2] * 2 - 0.5;
          finalLembur += jamLembur * (3 / 20) * jamKerja['gajiperhari'];
        } else if (value[2] <= 10) {
          jamLembur = value[2] * 3 - 8.5;
          finalLembur += jamLembur * (3 / 20) * jamKerja['gajiperhari'];
        } else if (value[2] <= 12) {
          jamLembur = value[2] * 4 - 18.5;
          finalLembur += jamLembur * (3 / 20) * jamKerja['gajiperhari'];
        }
      }
    });
    jam = hari % 8;
    finalHari = (hari / 8).floor();
    total = (finalHari * jamKerja['gajiperhari'] +
            jamKerja['gajiperhari'] / 8 * jam) +
        finalLembur +
        jamKerja['fullday'];
    if (mode == 'jml') {
      if (jam == 0) {
        hasil = '${finalHari.toString()} hari';
      } else {
        hasil = '${finalHari.toString()} hari ${jam.toString()} jam';
      }
    } else if (mode == 'lembur') {
      hasil = finalLembur.round().toString();
    } else if (mode == 'total') {
      hasil = total.round().toString();
    }
    return hasil;
  }

  List<Widget> _buildFirstColumn(List<DocumentSnapshot> document) {
    return List.generate(
      document[0]['data'].length + 1,
      (index) => Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.5, color: Colors.deepPurple),
          ),
        ),
        alignment: Alignment.centerLeft,
        width: 170.0,
        child: index == 0
            ? Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.sort, color: Colors.deepPurple),
                    onPressed: () {
                      setState(() {
                        sort = 'nama';
                        _descending ? _descending = false : _descending = true;
                      });
                    },
                  ),
                  Text('Nama',
                      style: new TextStyle(
                          fontSize: 17.0,
                          color: Colors.deepPurple,
                          fontWeight: FontWeight.bold)),
                ],
              )
            : Container(
                alignment: Alignment.centerLeft,
                width: 170.0,
                height: 73.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text(
                    document[0]['data'][index - 1]['nama'],
                    //'eefef',
                    style:
                        new TextStyle(fontSize: 15.0, color: Colors.deepPurple),
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildCells(int row, List<DocumentSnapshot> document) {
    return List.generate(
      headerTabel.length,
      (index) => Container(
        alignment: Alignment.centerLeft,
        width: columnSize[index],
        margin: EdgeInsets.only(left: 5.0),
        child: row == 0
            ? Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.sort, color: Colors.deepPurple),
                    onPressed: () {
                      setState(() {
                        sort = dataGet[index];
                        _descending ? _descending = false : _descending = true;
                      });
                    },
                  ),
                  Text(
                    headerTabel[index],
                    style: new TextStyle(
                        fontSize: 17.0,
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Container(
                alignment: Alignment.centerLeft,
                width: columnSize[index],
                height: 73.0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 47.0),
                  child: Text(
                    index >= 0 && index < 21
                        ? document[0]['data'][row - 1][dataGet[index]]
                                    [index % 3] ==
                                0
                            ? ''
                            : document[0]['data'][row - 1][dataGet[index]]
                                        [index % 3]
                                    .toString() +
                                ' jam'
                        : index == 21
                            ? _calculateJmlHaridanLembur(
                                document[0]['data'][row - 1], 'jml')
                            : index == 22
                                ? 'Rp. ' +
                                    document[0]['data'][row - 1][dataGet[index]]
                                        .toString()
                                : index == 23
                                    ? 'Rp. ' +
                                        _calculateJmlHaridanLembur(
                                            document[0]['data'][row - 1],
                                            'lembur')
                                    : index == 24
                                        ? document[0]['data'][row - 1]
                                                [dataGet[index]]
                                            .toString()
                                        : 'Rp. ' +
                                            _calculateJmlHaridanLembur(
                                                document[0]['data'][row - 1],
                                                'total'),
                    textAlign: TextAlign.left,
                    style:
                        new TextStyle(fontSize: 15.0, color: Colors.deepPurple),
                  ),
                ),
              ),
      ),
    );
  }

  List<Widget> _buildRows(List<DocumentSnapshot> document) {
    return List.generate(
      document[0]['data'].length + 1,
      (index) => Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 0.5, color: Colors.deepPurple),
          ),
        ),
        child: Row(
          children: _buildCells(index, document),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection(trial ? 'triallokasi' : 'lokasi')
        .orderBy('lokasi', descending: false)
        .get()
        .then((lokasiSnapshot) {
      lokasiSnapshot.docs.forEach((element) {
        _listLokasi.add(element.get('lokasi'));
      });
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.of(context).push(new MaterialPageRoute(
              builder: (BuildContext context) => AddAbsensiHarian(
                    lokasi: _tmpDrop,
                  )));
        },
      ),
      drawer: SideBar(
        page: 'absensi harian',
      ),
      bottomNavigationBar: new BottomAppBar(
        notchMargin: 5.0,
        shape: CircularNotchedRectangle(),
        color: Colors.deepOrange,
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Expanded(child: new SizedBox()),
            IconButton(
              icon: Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                if (editButton) {
                  print('a');
                }
              },
            )
          ],
        ),
      ),
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: new Text('Absensi Harian'),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  _tglAbsenHarian == null
                      ? 'Per tanggal'
                      : 'Per tanggal : ' +
                          "${_tglAbsenHarian.toLocal()}".split(' ')[0],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    onPressed: () {
                      _selectDates(context, _tglAbsenHarian, 1975, 2025, 2);
                    },
                  ),
                ],
              ),
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              DropdownButton(
                value: _tmpDrop,
                items: _listLokasi.map((e) {
                  return DropdownMenuItem(child: Text(e), value: e);
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tmpDrop = value;
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('absensiharian')
                      .where(
                        'tanggal',
                        isGreaterThanOrEqualTo:
                            _getStartorEndWeek(_tglAbsenHarian, 'bawah'),
                        isLessThanOrEqualTo:
                            _getStartorEndWeek(_tglAbsenHarian, 'atas'),
                      )
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      editButton = false;
                      return Container(
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      if (snapshot.data.docs.length == 0) {
                        return Container(
                          padding: EdgeInsets.only(top: 30.0),
                          child: Center(
                            child: SpinKitChasingDots(
                              duration: const Duration(milliseconds: 1000),
                              color: Colors.deepPurple,
                              size: 70.0,
                            ),
                          ),
                        );
                      } else {
                        query = [];
                        //query = snapshot.data.docs;

                        snapshot.data.docs.forEach((element) {
                          if (element.data().toString().contains(_tmpDrop)) {
                            query.add(element);
                          }
                        });

                        if (query.length == 0) {
                          editButton = false;
                          return Container(
                            padding: EdgeInsets.only(top: 30.0),
                            child: Center(
                              child: SpinKitChasingDots(
                                duration: const Duration(milliseconds: 1000),
                                color: Colors.deepPurple,
                                size: 70.0,
                              ),
                            ),
                          );
                        } else {
                          if (!_descending) {
                            query.sort((a, b) => a
                                .get(sort)
                                .toString()
                                .toLowerCase()
                                .compareTo(
                                    b.get(sort).toString().toLowerCase()));
                          } else {
                            query.sort((a, b) => b
                                .get(sort)
                                .toString()
                                .toLowerCase()
                                .compareTo(
                                    a.get(sort).toString().toLowerCase()));
                          }

                          editButton = true;
                          return Column(
                            children: [
                              Text(
                                query.length.toString() + ' data ditemukan',
                                style: TextStyle(color: Colors.deepOrange),
                              ),
                              Container(
                                child: SingleChildScrollView(
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: _buildFirstColumn(query),
                                      ),
                                      Flexible(
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: _buildRows(query),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      }
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
