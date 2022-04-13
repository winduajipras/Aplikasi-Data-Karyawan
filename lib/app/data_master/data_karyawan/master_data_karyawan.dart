import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jia/app/data_master/data_karyawan/add_karyawan.dart';
import 'package:jia/app/data_master/data_karyawan/edit_karyawan.dart';
import 'package:jia/app/data_master/data_karyawan/rekap_absen.dart';
import 'package:jia/app/data_master/data_karyawan/show_chart.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:jia/common_widgets/export_excel.dart';
import 'package:jia/common_widgets/sidebar.dart';
import 'package:age/age.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:network_state/network_state.dart';

class DataKaryawan extends StatefulWidget {
  final String nama;
  DataKaryawan({this.nama});
  @override
  _DataKaryawanState createState() => _DataKaryawanState();
}

class _DataKaryawanState extends State<DataKaryawan> {
  bool trial = false;
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final sideBarTextColor = Colors.white;
  final bodyTextColor = Colors.deepOrange;
  TextEditingController _searchController = TextEditingController();
  TextEditingController controllerNama;
  bool _isFiltered = false;
  bool _isLoading = false;
  bool _isLoadingAdd = false;
  bool _monthly = true;
  String _filteredResult = '';
  String _tmpFilteredResult = '';
  List _listKategori = [
    'nama',
    'nik',
    'ktp',
    'lokasi',
    'tempatLahir',
    'tglLahir',
    'pendidikan',
    'golonganDarah',
    'kelamin',
    'status',
    'anakLaki',
    'anakPerempuan',
    'ibuKandung',
    'tglMasuk',
    'tglKeluar',
    'aktif',
    'statusKontrak',
    'bagian',
    'klasifikasiGaji',
    'perusahaan',
    'bpjsKetenagakerjaan',
    'bpjsKesehatan',
  ];
  Map _listKategoriIcon = {
    'nama': Icons.person,
    'nik': Icons.card_membership,
    'ktp': Icons.chrome_reader_mode,
    'lokasi': Icons.location_on_rounded,
    'tempatLahir': Icons.home,
    'tglLahir': Icons.date_range_rounded,
    'pendidikan': Icons.school,
    'golonganDarah': Icons.whatshot_rounded,
    'kelamin': Icons.person_outline_sharp,
    'status': Icons.family_restroom_outlined,
    'anakLaki': Icons.child_friendly,
    'anakPerempuan': Icons.child_friendly_outlined,
    'ibuKandung': Icons.pregnant_woman_rounded,
    'tglMasuk': Icons.date_range_rounded,
    'tglKeluar': Icons.date_range_rounded,
    'aktif': Icons.work,
    'statusKontrak': Icons.supervised_user_circle_rounded,
    'bagian': Icons.label,
    'klasifikasiGaji': Icons.monetization_on_rounded,
    'perusahaan': Icons.location_city,
    'bpjsKetenagakerjaan': Icons.home_repair_service,
    'bpjsKesehatan': Icons.local_hospital,
  };
  Map _listKategoriShow = {
    'nama': 'Nama',
    'nik': 'NIK',
    'ktp': 'KTP',
    'lokasi': 'Lokasi',
    'tempatLahir': 'Tempat Lahir',
    'tglLahir': 'Tanggal Lahir',
    'pendidikan': 'Pendidikan',
    'golonganDarah': 'Golongan Darah',
    'kelamin': 'Kelamin',
    'status': 'Status',
    'anakLaki': 'Anak Laki-Laki',
    'anakPerempuan': 'Anak Perempuan',
    'ibuKandung': 'Ibu Kandung',
    'tglMasuk': 'Tanggal Masuk',
    'tglKeluar': 'Tanggal Keluar',
    'aktif': 'Status Kerja',
    'statusKontrak': 'Status Kontrak',
    'bagian': 'Jabatan',
    'klasifikasiGaji': 'Klasifikasi Gaji',
    'perusahaan': 'Perusahaan',
    'bpjsKetenagakerjaan': 'BPJS Ketenagakerjaan',
    'bpjsKesehatan': 'BPJS Kesehatan',
  };
  List<DocumentSnapshot> query;
  List<DocumentSnapshot> dupe;
  bool _descending = false;
  String sort = 'nama';
  String _kategori = 'nama';
  String _tmpKategori = 'nama';
  String _searchDBS = '';
  List _searchDBL = ['', '', '', ''];
  List<double> columnSize = [
    190.0,
    190.0,
    140.0,
    250.0,
    140.0,
    180.0,
    180.0,
    140.0,
    140.0,
    140.0,
    180.0,
    180.0,
    160.0,
    180.0,
    180.0,
    180.0,
    240.0,
    230.0,
    180.0,
    180.0,
    230.0,
    230.0,
    200.0,
    200.0,
    230.0,
    200.0,
    200.0,
    100.0,
    100.0,
    190.0,
    200.0,
    190.0,
    140.0,
  ];
  List dataGet = [
    'nik',
    'ktp',
    'lokasi',
    'alamat',
    'tempatLahir',
    'tglLahir',
    'pendidikan',
    'golonganDarah',
    'kelamin',
    'status',
    'anakLaki',
    'anakPerempuan',
    'ibuKandung',
    'tglMasuk',
    'tglKeluar',
    'aktif',
    [
      'pekerjaKontrakLaki',
      'pekerjaKontrakPerempuan',
      'pekerjaTetapLaki',
      'pekerjaTetapPerempuan',
    ],
    ['tglMasuk', 'tglKeluar'],
    'bagian',
    'klasifikasiGaji',
    'perusahaan',
    'bpjsKetenagakerjaan',
    'bpjsKetenagakerjaan',
    'bpjsKetenagakerjaan',
    'bpjsKesehatan',
    'bpjsKesehatan',
    'bpjsKesehatan',
    'vakum',
    'vakum',
    'vakum',
    'vakum',
    'vakum',
    'nama',
  ];

  List headerTabel = [
    'NIK',
    'KTP',
    'Lokasi',
    'Alamat',
    'Tempat Lahir',
    'Tanggal Lahir',
    'Pendidikan',
    'G. Darah',
    'Kelamin',
    'Status',
    'Anak Laki-laki',
    'Anak Perempuan',
    'Ibu Kandung',
    'Tanggal Masuk',
    'Tanggal Keluar',
    'Status Kerja',
    'Status Kontrak',
    'Masa Kerja',
    'Jabatan',
    'Klasifikasi Gaji',
    'Perusahaan',
    'BPJS Ketenagakerjaan',
    'Gabung BPJS Ket.',
    'Keluar BPJS Ket.',
    'BPJS Kesehatan',
    'Gabung BPJS Kes.',
    'Keluar BPJS Kes.',
    'Sakit',
    'Cuti',
    'Izin Dipotong (jam)',
    'Izin Tidak Dipotong',
    'Total Tidak Masuk',
    'Action',
  ];
  DateTime now = DateTime.now();
  DateTime now1 = DateTime.now();
  DateTime _tglMasaKerja = DateTime.now();
  DateTime _rangeKehadiran = firstDayOfMonth(DateTime.now(), true);
  DateTime _rangeKehadiran1 = lastDayOfMonth(DateTime.now(), true);
  DateTime filter;
  DateTime filter1;

  // _batchUpdate() {
  //   WriteBatch batch = FirebaseFirestore.instance.batch();
  //   query.forEach((element) {
  //     batch.set(
  //       element.reference,
  //       {'perusahaan': 'PT. Jatinom Indah Agri'},
  //       SetOptions(merge: true),
  //     );
  //   });
  //   batch.commit().then((value) {}).catchError((err) {});
  // }
  //

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
        else if (i == 2) _tglMasaKerja = picked;
      });
    }
  }

  static DateTime lastDayOfMonth(DateTime month, bool monthly) {
    var beginningNextMonth;
    if (monthly)
      (month.month < 12)
          ? beginningNextMonth = DateTime(month.year, month.month + 1, 1)
          : beginningNextMonth = DateTime(month.year + 1, 1, 1);
    else
      beginningNextMonth = DateTime(month.year + 1, 1, 1);

    return beginningNextMonth.subtract(new Duration(days: 1));
  }

  static DateTime firstDayOfMonth(DateTime month, bool monthly) {
    var beginningNextMonth;
    if (monthly)
      beginningNextMonth = new DateTime(month.year, month.month, 1);
    else
      beginningNextMonth = new DateTime(month.year, 1, 1);
    return beginningNextMonth;
  }

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

  _getMasaKerja(timestamp, timestamp1) {
    if (timestamp == null) return '';
    DateTime date =
        DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
    DateTime now = timestamp1 == null
        ? _tglMasaKerja
        : DateTime.fromMillisecondsSinceEpoch(timestamp1.seconds * 1000);
    AgeDuration masaKerja;
    masaKerja =
        Age.dateDifference(fromDate: date, toDate: now, includeToDate: false);
    if (masaKerja.years < 0)
      return '0 Tahun 0 Bulan 0 Hari';
    else
      return (masaKerja.years.toString() +
          ' Tahun ' +
          masaKerja.months.toString() +
          ' Bulan ' +
          masaKerja.days.toString() +
          ' Hari');
  }

  _statusKontrak(kl, kp, tl, tp) {
    if (kl == null || kp == null || tl == null || tp == null) return '';
    if (kl)
      return 'Pekerja Kontrak Laki-laki';
    else if (kp)
      return 'Pekerja Kontrak Perempuan';
    else if (tl)
      return 'Pekerja Tetap Laki-laki';
    else if (tp)
      return 'Pekerja Tetap Perempuan';
    else
      return '';
  }

  _bpjs(bpjs, index) {
    int setIndex = 21;
    if (index == setIndex || index == setIndex + 3) return bpjs[0];
    if (index == setIndex + 1 ||
        index == setIndex + 2 ||
        index == setIndex + 4 ||
        index == setIndex + 5) {
      var date;
      if (index == setIndex + 1 || index == setIndex + 4) {
        if (bpjs[1] == null)
          return '';
        else
          date = DateTime.fromMillisecondsSinceEpoch(bpjs[1].seconds * 1000);
      } else if (index == setIndex + 2 || index == setIndex + 5) {
        if (bpjs[2] == null)
          return '';
        else
          date = DateTime.fromMillisecondsSinceEpoch(bpjs[2].seconds * 1000);
      }
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
  }

  _kehadiran(List dataKehadiran, int index) {
    int setIndex = 27;
    if (dataKehadiran == null) return '';
    _rangeKehadiran = firstDayOfMonth(_tglMasaKerja, _monthly);
    _rangeKehadiran1 = lastDayOfMonth(_tglMasaKerja, _monthly);
    List<double> banyakKehadiran = [0, 0, 0, 0, 0];
    dataKehadiran.forEach((element) {
      if (element['tanggalVakum'].seconds >=
              Timestamp.fromDate(
                _rangeKehadiran.subtract(
                  Duration(
                      hours: _rangeKehadiran.hour,
                      minutes: _rangeKehadiran.minute,
                      seconds: _rangeKehadiran.second),
                ),
              ).seconds &&
          element['tanggalVakum'].seconds <=
              Timestamp.fromDate(
                _rangeKehadiran1.add(
                  Duration(
                      hours: 23 - _rangeKehadiran1.hour,
                      minutes: 59 - _rangeKehadiran1.minute,
                      seconds: 59 - _rangeKehadiran1.second),
                ),
              ).seconds) {
        if (element['kategori'] == 'Sakit') {
          banyakKehadiran[0]++;
          banyakKehadiran[4]++;
        } else if (element['kategori'] == 'Cuti') {
          banyakKehadiran[1]++;
          banyakKehadiran[4]++;
        } else if (element['kategori'] == 'Izin Dipotong') {
          if (double.tryParse(element['keterangan'].split(' ')[0]) != null) {
            banyakKehadiran[2] +=
                double.parse(element['keterangan'].split(' ')[0]);
            banyakKehadiran[4] +=
                double.parse(element['keterangan'].split(' ')[0]) / 7;
          }
        } else if (element['kategori'] == 'Izin Tidak Dipotong') {
          banyakKehadiran[3]++;
          banyakKehadiran[4]++;
        }
      }
    });

    if (index == setIndex)
      return banyakKehadiran[0].toString();
    else if (index == setIndex + 1)
      return banyakKehadiran[1].toString();
    else if (index == setIndex + 2)
      return banyakKehadiran[2].toStringAsFixed(2);
    else if (index == setIndex + 3)
      return banyakKehadiran[3].toString();
    else if (index == setIndex + 4)
      return banyakKehadiran[4].toStringAsFixed(2);
    else
      return '';
  }

  _stringFormater(String text, String mode) {
    if (text == '') return '';
    if (mode == 'firstCaps') {
      return '${text[0].toUpperCase()}${text.substring(1).toLowerCase()}';
    } else if (mode == 'eachFirstSecondCaps') {
      List<String> split = text.split(' ');
      List<String> convert = [];
      for (var i = 0; i < split.length; i++) {
        if (i == 0) {
          convert.add('${split[i].toUpperCase()}');
        } else {
          convert.add(
              '${split[i][0].toUpperCase()}${split[i].substring(1).toLowerCase()}');
        }
      }
      String hasil = convert.join(' ');
      return hasil;
    } else if (mode == 'eachFirstCaps') {
      List<String> split = text.split(' ');
      List<String> convert = [];
      split.forEach((element) {
        convert.add(
            '${element[0].toUpperCase()}${element.substring(1).toLowerCase()}');
      });
      String hasil = convert.join(' ');
      return hasil;
    }
  }

  List<Widget> _buildFirstColumn(List<DocumentSnapshot> document) {
    return List.generate(
      document.length + 1,
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
                    document[index - 1].get('nama'),
                    style: new TextStyle(
                        fontSize: 15.0,
                        color:
                            document[index - 1].get('aktif') == 'Masih Bekerja'
                                ? Colors.deepPurple
                                : Colors.deepOrange),
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
                      if (index == 17) {
                        setState(() {
                          sort = 'tglMasuk';
                          _descending
                              ? _descending = false
                              : _descending = true;
                        });
                      } else if (index != 16) {
                        setState(() {
                          sort = dataGet[index];
                          _descending
                              ? _descending = false
                              : _descending = true;
                        });
                      }
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
            : index == headerTabel.length - 1
                ? Container(
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.indigo),
                                onPressed: () {
                                  setState(() {
                                    _isLoading = true;
                                  });
                                  FirebaseFirestore.instance
                                      .collection(
                                          trial ? 'triallokasi' : 'lokasi')
                                      .orderBy('lokasi', descending: false)
                                      .get()
                                      .then((lokasiSnapshot) {
                                    FirebaseFirestore.instance
                                        .collection(
                                            trial ? 'trialjabatan' : 'jabatan')
                                        .orderBy('jabatan', descending: false)
                                        .get()
                                        .then((jabatanSnapshot) {
                                      FirebaseFirestore.instance
                                          .collection(trial
                                              ? 'trialperusahaan'
                                              : 'perusahaan')
                                          .orderBy('perusahaan',
                                              descending: false)
                                          .get()
                                          .then((perusahaanSnapshot) {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                EditKaryawan(
                                              trial: trial,
                                              document:
                                                  document[row - 1].data(),
                                              reference:
                                                  document[row - 1].reference,
                                              rangeKehadiran: _rangeKehadiran,
                                              rangeKehadiran1: _rangeKehadiran1,
                                              tglMasaKerja: _tglMasaKerja,
                                              lokasiSnapshot: lokasiSnapshot,
                                              jabatanSnapshot: jabatanSnapshot,
                                              perusahaanSnapshot:
                                                  perusahaanSnapshot,
                                            ),
                                          ),
                                        );
                                        setState(() {
                                          _isLoading = false;
                                        });
                                      });
                                    });
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    color: Colors.indigo),
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      String alertText =
                                          "Apakah anda yakin menghapus data karyawan [" +
                                              document[row - 1].get('nama') +
                                              "]";
                                      return AlertDialog(
                                        title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.warning,
                                                color: Colors.orange),
                                            Text(' Peringatan '),
                                            Icon(Icons.warning,
                                                color: Colors.orange),
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
                                                NetworkConfig.pollIntervalMs =
                                                    500;
                                                NetworkConfig.timeoutMs = 2000;

                                                NetworkState.startPolling();

                                                final ns = new NetworkState();
                                                bool key = false;
                                                ns.addListener(() async {
                                                  final hasConnection = key
                                                      ? false
                                                      : await ns.isConnected;
                                                  if (hasConnection) {
                                                    key = true;
                                                    FirebaseFirestore.instance
                                                        .runTransaction(
                                                            (transaction) async {
                                                      DocumentSnapshot
                                                          snapshot =
                                                          await transaction.get(
                                                              document[row - 1]
                                                                  .reference);
                                                      transaction.delete(
                                                          snapshot.reference);
                                                    });
                                                    Future.delayed(
                                                        Duration(
                                                            milliseconds: 500),
                                                        () {
                                                      Navigator.of(context)
                                                          .pop(true);
                                                      setState(() {
                                                        _isFiltered = false;
                                                        _isLoading = false;
                                                      });
                                                    });
                                                    NetworkState.stopPolling();
                                                  }
                                                  Future.delayed(
                                                      Duration(seconds: 6), () {
                                                    if (!key) {
                                                      key = true;
                                                      dialog(context,
                                                              'Periksa sambungan internet Anda')
                                                          .whenComplete(() =>
                                                              setState(() =>
                                                                  _isLoading =
                                                                      false));
                                                      NetworkState
                                                          .stopPolling();
                                                    }
                                                  });
                                                });
                                              },
                                              child: const Text("Ya")),
                                          ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                _isLoading = false;
                                              });
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
                            ],
                          ),
                  )
                : Container(
                    alignment: Alignment.centerLeft,
                    width: columnSize[index],
                    height: 73.0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 47.0),
                      child: Text(
                        index == 5 || index == 13 || index == 14
                            ? _getFormatedDate(
                                document[row - 1].get(dataGet[index]))
                            : index == 16
                                ? _statusKontrak(
                                    document[row - 1].get(dataGet[index][0]),
                                    document[row - 1].get(dataGet[index][1]),
                                    document[row - 1].get(dataGet[index][2]),
                                    document[row - 1].get(dataGet[index][3]))
                                : index == 17
                                    ? _getMasaKerja(
                                        document[row - 1]
                                            .get(dataGet[index][0]),
                                        document[row - 1]
                                            .get(dataGet[index][1]))
                                    : index >= 21 && index <= 26
                                        ? _bpjs(
                                            document[row - 1]
                                                .get(dataGet[index]),
                                            index)
                                        : index >= 27 && index <= 31
                                            ? _kehadiran(
                                                document[row - 1]
                                                    .get(dataGet[index]),
                                                index)
                                            : document[row - 1]
                                                .get(dataGet[index])
                                                .toString(),
                        textAlign: TextAlign.left,
                        style: new TextStyle(
                            fontSize: 15.0, color: Colors.deepPurple),
                      ),
                    ),
                  ),
      ),
    );
  }

  List<Widget> _buildRows(List<DocumentSnapshot> document) {
    return List.generate(
      document.length + 1,
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
    controllerNama = TextEditingController(text: widget.nama);
    _searchDBS = widget.nama;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _isLoadingAdd
          ? CircularProgressIndicator()
          : FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _isLoadingAdd = true;
                });
                FirebaseFirestore.instance
                    .collection(trial ? 'triallokasi' : 'lokasi')
                    .orderBy('lokasi', descending: false)
                    .get()
                    .then((lokasiSnapshot) {
                  FirebaseFirestore.instance
                      .collection(trial ? 'trialjabatan' : 'jabatan')
                      .orderBy('jabatan', descending: false)
                      .get()
                      .then((jabatanSnapshot) {
                    FirebaseFirestore.instance
                        .collection(trial ? 'trialperusahaan' : 'perusahaan')
                        .orderBy('perusahaan', descending: false)
                        .get()
                        .then((perusahaanSnapshot) {
                      Navigator.of(context).push(new MaterialPageRoute(
                          builder: (BuildContext context) => AddKaryawan(
                                trial: trial,
                                lokasiSnapshot: lokasiSnapshot,
                                jabatanSnapshot: jabatanSnapshot,
                                perusahaanSnapshot: perusahaanSnapshot,
                              )));
                      setState(() {
                        _isFiltered = false;
                        _isLoadingAdd = false;
                      });
                    });
                  });
                });
              },
            ),
      drawer: SideBar(
        page: 'data karyawan',
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
            _tmpKategori == 'lokasi'
                ? Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.post_add_rounded, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).push(
                            new MaterialPageRoute(
                              builder: (BuildContext context) => RekapAbsen(
                                query: _isFiltered ? dupe : query,
                                rangeKehadiran:
                                    firstDayOfMonth(_tglMasaKerja, _monthly),
                                rangeKehadiran1:
                                    lastDayOfMonth(_tglMasaKerja, _monthly),
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon:
                            Icon(Icons.show_chart_rounded, color: Colors.white),
                        onPressed: () {
                          Navigator.of(context).push(
                            new MaterialPageRoute(
                              builder: (BuildContext context) => ShowChart(
                                lokasi: _searchDBS,
                                query: _isFiltered ? dupe : query,
                                rangeKehadiran: _rangeKehadiran,
                                rangeKehadiran1: _rangeKehadiran1,
                                monthly: _monthly,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  )
                : SizedBox(),
            IconButton(
              icon: Icon(Icons.file_download, color: Colors.white),
              onPressed: () {
                generateExcel(
                    _isFiltered ? dupe : query, 0, null, null, _tglMasaKerja);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.filter_alt_outlined,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isFiltered ? _isFiltered = false : _isFiltered = true;
                });
                // _batchUpdate();
              },
            ),
          ],
        ),
      ),
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: new Text('Data Karyawan'),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(
                  _tglMasaKerja == null
                      ? 'Per tanggal'
                      : 'Per tanggal : ' +
                          "${_tglMasaKerja.toLocal()}".split(' ')[0],
                ),
              ),
              Row(
                children: [
                  Text(_monthly ? 'Bulanan' : 'Tahunan'),
                  Switch(
                    activeColor: Colors.deepOrange[100],
                    value: _monthly,
                    onChanged: (val) {
                      setState(() => val ? _monthly = true : _monthly = false);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today, color: Colors.white),
                    onPressed: () {
                      _selectDates(context, _tglMasaKerja, 1975, 2025, 2);
                    },
                  ),
                ],
              ),
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  DropdownButton(
                    icon: Icon(_listKategoriIcon[_tmpKategori]),
                    value: _tmpKategori,
                    items: _listKategori.map((e) {
                      return DropdownMenuItem(
                          child: Text(_listKategoriShow[e]), value: e);
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _tmpKategori = value;
                        _kategori = ' ';
                        filter = DateTime.now();
                        filter1 = DateTime.now();
                      });
                    },
                  ),
                  _tmpKategori == 'tglMasuk' ||
                          _tmpKategori == 'tglKeluar' ||
                          _tmpKategori == 'tglLahir'
                      ? Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: Row(
                            children: [
                              Flexible(
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  readOnly: true,
                                  onTap: () => _selectDates(
                                      context,
                                      now,
                                      _tmpKategori == 'tglLahir' ? 1945 : 1975,
                                      2025,
                                      0),
                                  decoration: new InputDecoration(
                                    icon: Icon(Icons.calendar_today),
                                    hintText: "${now.toLocal()}".split(' ')[0],
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Text('s.d.'),
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: TextField(
                                    textAlign: TextAlign.center,
                                    readOnly: true,
                                    onTap: () => _selectDates(
                                        context,
                                        now1,
                                        _tmpKategori == 'tglLahir'
                                            ? 1945
                                            : 1975,
                                        2025,
                                        1),
                                    decoration: new InputDecoration(
                                      icon: Icon(Icons.calendar_today),
                                      hintText:
                                          "${now1.toLocal()}".split(' ')[0],
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  setState(() {
                                    _kategori = _tmpKategori;
                                    filter = now;
                                    filter1 = now1;
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: MediaQuery.of(context).size.width * 0.65,
                          child: TextField(
                            controller: controllerNama,
                            onChanged: (String str) {
                              _searchDBS = str;
                            },
                            decoration: InputDecoration(
                              labelText: 'Cari Data',
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () {
                                  if (_tmpKategori == 'anakLaki' ||
                                      _tmpKategori == 'anakPerempuan') {
                                    setState(() {
                                      _kategori = _tmpKategori;
                                      _searchDBL = [int.parse(_searchDBS)];
                                    });
                                  } else if (_tmpKategori == 'statusKontrak') {
                                    if (_searchDBS == 'pkl' ||
                                        _searchDBS == 'PKL' ||
                                        _searchDBS == 'Pkl') {
                                      setState(() {
                                        _kategori = 'pekerjaKontrakLaki';
                                        _searchDBL = [true];
                                      });
                                    } else if (_searchDBS == 'pkp' ||
                                        _searchDBS == 'PKP' ||
                                        _searchDBS == 'Pkp') {
                                      setState(() {
                                        _kategori = 'pekerjaKontrakPerempuan';
                                        _searchDBL = [true];
                                      });
                                    } else if (_searchDBS == 'ptp' ||
                                        _searchDBS == 'PTP' ||
                                        _searchDBS == 'Ptp') {
                                      setState(() {
                                        _kategori = 'pekerjaTetapPerempuan';
                                        _searchDBL = [true];
                                      });
                                    } else if (_searchDBS == 'ptl' ||
                                        _searchDBS == 'PTL' ||
                                        _searchDBS == 'Ptl') {
                                      setState(() {
                                        _kategori = 'pekerjaTetapLaki';
                                        _searchDBL = [true];
                                      });
                                    } else {
                                      setState(() {
                                        _kategori = ' ';
                                      });
                                    }
                                  } else if (_tmpKategori == 'perusahaan') {
                                    setState(() {
                                      _kategori = _tmpKategori;
                                      _searchDBL = [
                                        _searchDBS.toLowerCase(),
                                        _searchDBS.toUpperCase(),
                                        _stringFormater(
                                            _searchDBS, 'eachFirstCaps'),
                                        _stringFormater(
                                            _searchDBS, 'firstCaps'),
                                        _stringFormater(
                                            _searchDBS, 'eachFirstSecondCaps')
                                      ];
                                    });
                                  } else {
                                    setState(() {
                                      _kategori = _tmpKategori;
                                      _searchDBL = [
                                        _searchDBS.toLowerCase(),
                                        _searchDBS.toUpperCase(),
                                        _stringFormater(
                                            _searchDBS, 'eachFirstCaps'),
                                        _stringFormater(_searchDBS, 'firstCaps')
                                      ];
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: StreamBuilder(
                      stream: _kategori == 'bpjsKetenagakerjaan' ||
                              _kategori == 'bpjsKesehatan'
                          ? FirebaseFirestore.instance
                              .collection(trial ? 'trialuser' : 'user')
                              .where(_kategori, arrayContainsAny: _searchDBL)
                              .snapshots()
                          : _kategori == 'tglMasuk' ||
                                  _kategori == 'tglKeluar' ||
                                  _kategori == 'tglLahir'
                              ? FirebaseFirestore.instance
                                  .collection(trial ? 'trialuser' : 'user')
                                  .where(
                                    _kategori,
                                    isGreaterThanOrEqualTo: Timestamp.fromDate(
                                      filter.subtract(
                                        Duration(
                                            hours: filter.hour,
                                            minutes: filter.minute,
                                            seconds: filter.second),
                                      ),
                                    ),
                                    isLessThanOrEqualTo: Timestamp.fromDate(
                                      filter1.add(
                                        Duration(
                                            hours: 23 - filter1.hour,
                                            minutes: 59 - filter1.minute,
                                            seconds: 59 - filter1.second),
                                      ),
                                    ),
                                  )
                                  .snapshots()
                              : FirebaseFirestore.instance
                                  .collection(trial ? 'trialuser' : 'user')
                                  .where(_kategori, whereIn: _searchDBL)
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
                            //========database error checker=======
                            // int id = 0;
                            // bool detect = false;
                            // List<DocumentSnapshot> query = snapshot.data.docs;
                            // query.forEach((element) {
                            //   element.data().forEach((key, value) {
                            //     if (key == 'pekerjaKontrakLaki') {
                            //       if (value == true || value == false) {
                            //         id++;
                            //         detect = true;
                            //       }
                            //     }
                            //   });
                            //   if (detect) {
                            //     detect = false;
                            //   } else {
                            //     print(element.get('nama'));
                            //   }
                            // });
                            // print(id.toString());
                            query = [];
                            query = snapshot.data.docs;

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

                            if (_isFiltered) {
                              dupe = [];
                              query.forEach((element) {
                                if (element
                                    .data()
                                    .toString()
                                    .toLowerCase()
                                    .contains(_filteredResult)) {
                                  dupe.add(element);
                                }
                              });
                            }

                            return Column(
                              children: [
                                Text(
                                  _isFiltered
                                      ? dupe.length.toString() +
                                          ' data tersaring dari ' +
                                          query.length.toString() +
                                          ' data yang ditemukan'
                                      : query.length.toString() +
                                          ' data ditemukan',
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
                                          children: _buildFirstColumn(
                                              _isFiltered ? dupe : query),
                                        ),
                                        Flexible(
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.horizontal,
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: _buildRows(
                                                  _isFiltered ? dupe : query),
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
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
          _isFiltered
              ? Container(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            bottom: 40.0, right: 15.0, left: 15.0),
                        child: Opacity(
                          opacity: 0.5,
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: "Saring",
                              hintText: "Saring",
                              prefixIcon: IconButton(
                                icon: Icon(Icons.filter_alt_outlined,
                                    color: Colors.deepOrange),
                                onPressed: () {
                                  setState(() {
                                    _filteredResult = _tmpFilteredResult;
                                  });
                                },
                              ),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : InkWell(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {
                                          _tmpFilteredResult = '';
                                          _filteredResult = '';
                                        });
                                      },
                                      child: Icon(Icons.clear),
                                    ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15.0),
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              _tmpFilteredResult = value;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Container()
        ],
      ),
    );
  }
}
