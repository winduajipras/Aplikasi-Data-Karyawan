import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jia/app/data_master/data_karyawan/add_karyawan.dart';
import 'package:jia/app/data_master/data_karyawan/print_karyawan.dart';
import 'package:jia/app/data_master/data_karyawan/public_edit_karyawan.dart';
import 'package:jia/common_widgets/export_excel.dart';
import 'package:age/age.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

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

  QuerySnapshot _snapshot;
  TextEditingController controllerNama;
  PanelController _pc = new PanelController();
  bool _isFiltered = false;
  bool _isLoading = false;
  bool _isLoadingAdd = false;
  bool _statusKontrakPekerja = false;
  List _listLokasi = [];
  List _listPendidikan = [
    'SD',
    'SLTP',
    'SLTA',
    'SMK',
    'D1',
    'D2',
    'D3',
    'D4',
    'S1',
    'S2',
    'S3'
  ];
  List _listGolonganDarah = [
    'A',
    'B',
    'AB',
    'O',
  ];
  List _listKelamin = [
    'Laki-laki',
    'Perempuan',
  ];
  List _listStatus = [
    'Kawin',
    'Belum Kawin',
  ];
  List _listAktif = [
    'Masih Bekerja',
    'Keluar',
  ];
  List _listStatusKontrak = [
    'Pekerja Kontrak Laki-laki',
    'Pekerja Kontrak Perempuan',
    'Pekerja Tetap Laki-laki',
    'Pekerja Tetap Perempuan',
    'Pekerja Harian Tetap Laki-laki',
    'Pekerja Harian Tetap Perempuan',
    'Pekerja Harian Tidak Tetap Laki-laki',
    'Pekerja Harian Tidak Tetap Perempuan',
  ];
  List _listBagian = [];
  List _listKlasifikasiGaji = [
    'HARIAN',
    'MINGGUAN',
    'BULANAN',
  ];
  List _listPerusahaan = [];
  String _tmpLokasi;
  String _tmpPendidikan;
  String _tmpGolonganDarah;
  String _tmpKelamin;
  String _tmpStatus;
  String _tmpAktif;
  String _tmpStatusKontrak;
  String _tmpBagian;
  String _tmpKlasifikasiGaji;
  String _tmpPerusahaan;
  Map _filterResult = {
    'nama': '',
    'nik': '',
    'ktp': '',
    'lokasi': '',
    'tempatLahir': '',
    'tglLahir': {
      'awal': DateTime(1940, 1, 1),
      'akhir': DateTime.now(),
    },
    'pendidikan': '',
    'sekolah': '',
    'jurusan': '',
    'golonganDarah': '',
    'kelamin': '',
    'status': '',
    'anakLaki': '',
    'anakPerempuan': '',
    'ibuKandung': '',
    'tglMasuk': {
      'awal': DateTime(1970, 1, 1),
      'akhir': DateTime.now(),
    },
    'aktif': '',
    'statusKontrak': {
      'pekerjaKontrakLaki': false,
      'pekerjaKontrakPerempuan': false,
      'pekerjaTetapLaki': false,
      'pekerjaTetapPerempuan': false,
      'pekerjaHarianTetapLaki': false,
      'pekerjaHarianTetapPerempuan': false,
      'pekerjaHarianTidakTetapLaki': false,
      'pekerjaHarianTidakTetapPerempuan': false,
    },
    'bagian': '',
    'klasifikasiGaji': '',
    'perusahaan': '',
    'bpjsKetenagakerjaan': '',
    'bpjsKesehatan': '',
  };

  List _listKategori = [
    'nama',
    'nik',
    'ktp',
    'lokasi',
    'tempatLahir',
    'tglLahir',
    'pendidikan',
    'sekolah',
    'jurusan',
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
    'sekolah': Icons.local_library,
    'jurusan': Icons.explore,
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
    'nama': 'Nama Lengkap',
    'nik': 'NIK',
    'ktp': 'KTP',
    'lokasi': 'Lokasi',
    'tempatLahir': 'Tempat Lahir',
    'tglLahir': 'Tanggal Lahir',
    'pendidikan': 'Pendidikan Terakhir',
    'sekolah': 'Nama Sekolah',
    'jurusan': 'Jurusan',
    'golonganDarah': 'Golongan Darah',
    'kelamin': 'Jenis Kelamin',
    'status': 'Status Perkawinan',
    'anakLaki': 'Jumlah Anak Laki-Laki',
    'anakPerempuan': 'Jumlah Anak Perempuan',
    'ibuKandung': 'Nama Ibu Kandung',
    'tglMasuk': 'Tanggal Masuk',
    'tglKeluar': 'Tanggal Keluar',
    'aktif': 'Status Kerja',
    'statusKontrak': 'Status Pekerja',
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
    'sekolah',
    'jurusan',
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
      'pekerjaHarianTetapLaki',
      'pekerjaHarianTetapPerempuan',
      'pekerjaHarianTidakTetapLaki',
      'pekerjaHarianTidakTetapPerempuan',
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
    'Sekolah',
    'Jurusan',
    'G. Darah',
    'Kelamin',
    'Status',
    'Anak Laki-laki',
    'Anak Perempuan',
    'Ibu Kandung',
    'Tanggal Masuk',
    'Tanggal Keluar',
    'Status Kerja',
    'Status Pekerja',
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
  //       {
  //         'lokasi': 'JI FOOD BLITAR',
  //       },
  //       SetOptions(merge: true),
  //     );
  //   });
  //   batch.commit().then((value) {}).catchError((err) {});
  // }

  _filterBatch(DocumentSnapshot element) {
    if (element.get('nama').toString().toLowerCase().contains(_filterResult['nama']) &&
        element
            .get('nik')
            .toString()
            .toLowerCase()
            .contains(_filterResult['nik']) &&
        element
            .get('ktp')
            .toString()
            .toLowerCase()
            .contains(_filterResult['ktp']) &&
        element.get('lokasi').toString().contains(_filterResult['lokasi']) &&
        element
            .get('tempatLahir')
            .toString()
            .toLowerCase()
            .contains(_filterResult['tempatLahir']) &&
        (element.get('tglLahir').seconds >= Timestamp.fromDate(_filterResult['tglLahir']['awal']).seconds &&
            element.get('tglLahir').seconds <=
                Timestamp.fromDate(_filterResult['tglLahir']['akhir'])
                    .seconds) &&
        element
            .get('pendidikan')
            .toString()
            .contains(_filterResult['pendidikan']) &&
        element
            .get('sekolah')
            .toString()
            .toLowerCase()
            .contains(_filterResult['sekolah']) &&
        element
            .get('jurusan')
            .toString()
            .toLowerCase()
            .contains(_filterResult['jurusan']) &&
        element
            .get('golonganDarah')
            .toString()
            .contains(_filterResult['golonganDarah']) &&
        element.get('kelamin').toString().contains(_filterResult['kelamin']) &&
        (_filterResult['status'] == ''
            ? element.get('status').toString().contains(_filterResult['status'])
            : element.get('status').toString() == _filterResult['status']) &&
        element
            .get('anakLaki')
            .toString()
            .toLowerCase()
            .contains(_filterResult['anakLaki']) &&
        element
            .get('anakPerempuan')
            .toString()
            .toLowerCase()
            .contains(_filterResult['anakPerempuan']) &&
        element
            .get('ibuKandung')
            .toString()
            .toLowerCase()
            .contains(_filterResult['ibuKandung']) &&
        (element.get('tglMasuk').seconds >= Timestamp.fromDate(_filterResult['tglMasuk']['awal']).seconds &&
            element.get('tglMasuk').seconds <=
                Timestamp.fromDate(_filterResult['tglMasuk']['akhir'])
                    .seconds) &&
        element.get('aktif').toString().contains(_filterResult['aktif']) &&
        (_statusKontrakPekerja
            ? (element.get('pekerjaKontrakLaki') == _filterResult['statusKontrak']['pekerjaKontrakLaki'] &&
                element.get('pekerjaKontrakPerempuan') ==
                    _filterResult['statusKontrak']['pekerjaKontrakPerempuan'] &&
                element.get('pekerjaTetapLaki') ==
                    _filterResult['statusKontrak']['pekerjaTetapLaki'] &&
                element.get('pekerjaTetapPerempuan') ==
                    _filterResult['statusKontrak']['pekerjaTetapPerempuan'] &&
                element.get('pekerjaHarianTetapLaki') ==
                    _filterResult['statusKontrak']['pekerjaHarianTetapLaki'] &&
                element.get('pekerjaHarianTetapPerempuan') ==
                    _filterResult['statusKontrak']
                        ['pekerjaHarianTetapPerempuan'] &&
                element.get('pekerjaHarianTidakTetapLaki') ==
                    _filterResult['statusKontrak']['pekerjaHarianTidakTetapLaki'] &&
                element.get('pekerjaHarianTidakTetapPerempuan') == _filterResult['statusKontrak']['pekerjaHarianTidakTetapPerempuan'])
            : true) &&
        element.get('bagian').toString().contains(_filterResult['bagian']) &&
        element.get('klasifikasiGaji').toString().contains(_filterResult['klasifikasiGaji']) &&
        element.get('perusahaan').toString().contains(_filterResult['perusahaan']) &&
        element.get('bpjsKetenagakerjaan')[0].toString().toLowerCase().contains(_filterResult['bpjsKetenagakerjaan']) &&
        element.get('bpjsKesehatan')[0].toString().toLowerCase().contains(_filterResult['bpjsKesehatan'])) {
      return true;
    } else {
      return false;
    }
  }

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

  Future _selectDateRange(BuildContext context, String mode) async {
    DateTimeRange pickedRange = await showDateRangePicker(
        initialEntryMode: DatePickerEntryMode.inputOnly,
        context: context,
        initialDateRange: DateTimeRange(
          start: _filterResult[mode]['awal'],
          end: _filterResult[mode]['akhir'],
        ),
        firstDate: DateTime(1940, 1, 1),
        lastDate: DateTime(DateTime.now().year + 2),
        helpText: 'Rentang Tanggal',
        cancelText: 'CANCEL',
        confirmText: 'OK',
        saveText: 'SAVE',
        errorFormatText: 'Format Tanggal Salah',
        errorInvalidText: 'Tanggal Diluar Jangkauan',
        errorInvalidRangeText: 'Rentang Salah',
        fieldStartHintText: 'bb/hh/tttt',
        fieldEndHintText: 'bb/hh/tttt',
        fieldStartLabelText: 'Mulai Tanggal',
        fieldEndLabelText: 'Sampai Tanggal');

    if (pickedRange != null) {
      if (mode == 'tglLahir') {
        _filterResult['tglLahir']['awal'] = pickedRange.start;
        _filterResult['tglLahir']['akhir'] = pickedRange.end;
      } else if (mode == 'tglMasuk') {
        _filterResult['tglMasuk']['awal'] = pickedRange.start;
        _filterResult['tglMasuk']['akhir'] = pickedRange.end;
      }
      setState(() {});
    }
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

  _statusKontrak(kl, kp, tl, tp, htl, htp, httl, http) {
    if (kl == null ||
        kp == null ||
        tl == null ||
        tp == null ||
        htl == null ||
        htp == null ||
        httl == null ||
        http == null) return '';
    if (kl)
      return 'Pekerja Kontrak Laki-laki';
    else if (kp)
      return 'Pekerja Kontrak Perempuan';
    else if (tl)
      return 'Pekerja Tetap Laki-laki';
    else if (tp)
      return 'Pekerja Tetap Perempuan';
    else if (htl)
      return 'Pekerja Harian Tetap Laki-laki';
    else if (htp)
      return 'Pekerja Harian Tetap Perempuan';
    else if (httl)
      return 'Pekerja Harian Tidak Tetap Laki-laki';
    else if (http)
      return 'Pekerja Harian Tidak Tetap Perempuan';
    else
      return '';
  }

  _bpjs(bpjs, index) {
    int setIndex = 23;
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
                      if (index == 19) {
                        setState(() {
                          sort = 'tglMasuk';
                          _descending
                              ? _descending = false
                              : _descending = true;
                        });
                      } else if (index != 18) {
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
                                icon: Icon(Icons.print, color: Colors.indigo),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          PrintKaryawan(
                                        document: document[row - 1].data(),
                                        tglMasaKerja: _tglMasaKerja,
                                      ),
                                    ),
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
                        index == 5 || index == 15 || index == 16
                            ? _getFormatedDate(
                                document[row - 1].get(dataGet[index]))
                            : index == 18
                                ? _statusKontrak(
                                    document[row - 1].get(dataGet[index][0]),
                                    document[row - 1].get(dataGet[index][1]),
                                    document[row - 1].get(dataGet[index][2]),
                                    document[row - 1].get(dataGet[index][3]),
                                    document[row - 1].get(dataGet[index][4]),
                                    document[row - 1].get(dataGet[index][5]),
                                    document[row - 1].get(dataGet[index][6]),
                                    document[row - 1].get(dataGet[index][7]),
                                  )
                                : index == 19
                                    ? _getMasaKerja(
                                        document[row - 1]
                                            .get(dataGet[index][0]),
                                        document[row - 1]
                                            .get(dataGet[index][1]))
                                    : index >= 23 && index <= 28
                                        ? _bpjs(
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

  _buildTable() {
    if (_snapshot.docs.isEmpty) {
      return Column(
        children: [
          Text('Data Tidak Ditemukan'),
          Container(
            padding: EdgeInsets.only(top: 30.0),
            child: Center(
              child: SpinKitChasingDots(
                duration: const Duration(milliseconds: 1000),
                color: Colors.deepPurple,
                size: 70.0,
              ),
            ),
          )
        ],
      );
    } else {
      query = [];
      query = _snapshot.docs;

      if (!_descending) {
        query.sort((a, b) => a
            .get(sort)
            .toString()
            .toLowerCase()
            .compareTo(b.get(sort).toString().toLowerCase()));
      } else {
        query.sort((a, b) => b
            .get(sort)
            .toString()
            .toLowerCase()
            .compareTo(a.get(sort).toString().toLowerCase()));
      }

      if (_isFiltered) {
        dupe = [];
        query.forEach((element) {
          // if (element
          //     .data()
          //     .toString()
          //     .toLowerCase()
          //     .contains(_filteredResult)) {
          //   dupe.add(element);
          // }
          if (_filterBatch(element)) {
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
                : query.length.toString() + ' data ditemukan',
            style: TextStyle(color: Colors.deepOrange),
          ),
          Container(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _buildFirstColumn(_isFiltered ? dupe : query),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _buildRows(_isFiltered ? dupe : query),
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

  @override
  void initState() {
    super.initState();
    controllerNama = TextEditingController(text: widget.nama);
    _searchDBS = widget.nama;
    FirebaseFirestore.instance
        .collection(trial ? 'triallokasi' : 'lokasi')
        .orderBy('lokasi', descending: false)
        .get()
        .then((lokasiSnapshot) {
      lokasiSnapshot.docs.forEach((element) {
        _listLokasi.add(element.get('lokasi'));
      });
    });
    FirebaseFirestore.instance
        .collection(trial ? 'trialjabatan' : 'jabatan')
        .orderBy('jabatan', descending: false)
        .get()
        .then((bagianSnapshot) {
      bagianSnapshot.docs.forEach((element) {
        _listBagian.add(element.get('jabatan'));
      });
    });
    FirebaseFirestore.instance
        .collection(trial ? 'trialperusahaan' : 'perusahaan')
        .orderBy('perusahaan', descending: false)
        .get()
        .then((perusahaanSnapshot) {
      perusahaanSnapshot.docs.forEach((element) {
        _listPerusahaan.add(element.get('perusahaan'));
      });
    });
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
        bottomNavigationBar: new BottomAppBar(
          notchMargin: 5.0,
          shape: CircularNotchedRectangle(),
          color: Colors.deepOrange,
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Versi : 1.35.2',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              Expanded(child: SizedBox()),
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
                  // setState(() {
                  //   _isFiltered ? _isFiltered = false : _isFiltered = true;
                  // });
                  // _batchUpdate();
                  _pc.isPanelOpen ? _pc.close() : _pc.open();
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
        body: SlidingUpPanel(
          controller: _pc,
          minHeight: 0.0,
          backdropEnabled: true,
          panel: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        color: Colors.deepPurple,
                        icon: Icon(Icons.search),
                        onPressed: () {
                          setState(() => _isFiltered = true);
                          _pc.close();
                        },
                      ),
                      IconButton(
                        color: Colors.deepPurple,
                        icon: Icon(Icons.search_off),
                        onPressed: () {
                          setState(() => _isFiltered = false);
                          _pc.close();
                        },
                      ),
                    ],
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['nama']),
                      labelText: 'Cari Nama',
                      border: InputBorder.none,
                    ),
                    onChanged: (str) {
                      _filterResult['nama'] = str;
                    },
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['nik']),
                      labelText: 'Cari NIK',
                      border: InputBorder.none,
                    ),
                    onChanged: (str) {
                      _filterResult['nik'] = str;
                    },
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['ktp']),
                      labelText: 'Cari KTP',
                      border: InputBorder.none,
                    ),
                    onChanged: (str) {
                      _filterResult['ktp'] = str;
                    },
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['lokasi'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Lokasi'),
                        value: _tmpLokasi,
                        items: _listLokasi.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterResult['lokasi'] = value;
                          setState(() {
                            _tmpLokasi = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _tmpLokasi = null;
                              _filterResult['lokasi'] = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['tempatLahir']),
                      labelText: 'Cari Tempat Lahir',
                      border: InputBorder.none,
                    ),
                    onChanged: (str) {
                      _filterResult['tempatLahir'] = str;
                    },
                  ),
                  TextField(
                    readOnly: true,
                    onTap: () => _selectDateRange(context, 'tglLahir'),
                    decoration: new InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      hintText:
                          'Cari Tanggal Lahir : ${_filterResult['tglLahir']['awal'].toString().split(' ')[0]} sampai ${_filterResult['tglLahir']['akhir'].toString().split(' ')[0]}',
                      border: InputBorder.none,
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['pendidikan'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Pendidikan Terakhir'),
                        value: _tmpPendidikan,
                        items: _listPendidikan.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterResult['pendidikan'] = value;
                          setState(() {
                            _tmpPendidikan = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _tmpPendidikan = null;
                              _filterResult['pendidikan'] = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['sekolah']),
                      labelText: 'Cari Sekolah',
                      border: InputBorder.none,
                    ),
                    onChanged: (str) {
                      _filterResult['sekolah'] = str;
                    },
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['jurusan']),
                      labelText: 'Cari Jurusan',
                      border: InputBorder.none,
                    ),
                    onChanged: (str) {
                      _filterResult['jurusan'] = str;
                    },
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['golonganDarah'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Golongan Darah'),
                        value: _tmpGolonganDarah,
                        items: _listGolonganDarah.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterResult['golonganDarah'] = value;
                          setState(() {
                            _tmpGolonganDarah = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _tmpGolonganDarah = null;
                              _filterResult['golonganDarah'] = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['kelamin'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Jenis Kelamin'),
                        value: _tmpKelamin,
                        items: _listKelamin.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterResult['kelamin'] = value;
                          setState(() {
                            _tmpKelamin = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _tmpKelamin = null;
                              _filterResult['kelamin'] = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Divider(),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['status'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Status Perkawinan'),
                        value: _tmpStatus,
                        items: _listStatus.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterResult['status'] = value;
                          setState(() {
                            _tmpStatus = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _tmpStatus = null;
                              _filterResult['status'] = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['anakLaki']),
                      labelText: 'Cari Jumlah Anak Laki-laki',
                      border: InputBorder.none,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (str) {
                      _filterResult['anakLaki'] = str;
                    },
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['anakPerempuan']),
                      labelText: 'Cari Jumlah Anak Perempuan',
                      border: InputBorder.none,
                    ),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (str) {
                      _filterResult['anakPerempuan'] = str;
                    },
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['ibuKandung']),
                      labelText: 'Cari Nama Ibu Kandung',
                      border: InputBorder.none,
                    ),
                    onChanged: (str) {
                      _filterResult['ibuKandung'] = str;
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Divider(),
                  ),
                  TextField(
                    readOnly: true,
                    onTap: () => _selectDateRange(context, 'tglMasuk'),
                    decoration: new InputDecoration(
                      icon: Icon(Icons.calendar_today),
                      hintText:
                          'Cari Tanggal Masuk : ${_filterResult['tglMasuk']['awal'].toString().split(' ')[0]} sampai ${_filterResult['tglMasuk']['akhir'].toString().split(' ')[0]}',
                      border: InputBorder.none,
                    ),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['aktif'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Status Kerja'),
                        value: _tmpAktif,
                        items: _listAktif.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterResult['aktif'] = value;
                          setState(() {
                            _tmpAktif = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _tmpAktif = null;
                              _filterResult['aktif'] = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['statusKontrak'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Status Pekerja'),
                        value: _tmpStatusKontrak,
                        items: _listStatusKontrak.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _statusKontrakPekerja = true;
                          _filterResult['statusKontrak'] = {
                            'pekerjaKontrakLaki': false,
                            'pekerjaKontrakPerempuan': false,
                            'pekerjaTetapLaki': false,
                            'pekerjaTetapPerempuan': false,
                            'pekerjaHarianTetapLaki': false,
                            'pekerjaHarianTetapPerempuan': false,
                            'pekerjaHarianTidakTetapLaki': false,
                            'pekerjaHarianTidakTetapPerempuan': false,
                          };
                          if (value == 'Pekerja Kontrak Laki-laki') {
                            _filterResult['statusKontrak']
                                ['pekerjaKontrakLaki'] = true;
                            setState(() {
                              _tmpStatusKontrak = value;
                            });
                          } else if (value == 'Pekerja Kontrak Perempuan') {
                            _filterResult['statusKontrak']
                                ['pekerjaKontrakPerempuan'] = true;
                            setState(() {
                              _tmpStatusKontrak = value;
                            });
                          } else if (value == 'Pekerja Tetap Laki-laki') {
                            _filterResult['statusKontrak']['pekerjaTetapLaki'] =
                                true;
                            setState(() {
                              _tmpStatusKontrak = value;
                            });
                          } else if (value == 'Pekerja Tetap Perempuan') {
                            _filterResult['statusKontrak']
                                ['pekerjaTetapPerempuan'] = true;
                            setState(() {
                              _tmpStatusKontrak = value;
                            });
                          } else if (value ==
                              'Pekerja Harian Tetap Laki-laki') {
                            _filterResult['statusKontrak']
                                ['pekerjaHarianTetapLaki'] = true;
                            setState(() {
                              _tmpStatusKontrak = value;
                            });
                          } else if (value ==
                              'Pekerja Harian Tetap Perempuan') {
                            _filterResult['statusKontrak']
                                ['pekerjaHarianTetapPerempuan'] = true;
                            setState(() {
                              _tmpStatusKontrak = value;
                            });
                          } else if (value ==
                              'Pekerja Harian Tidak Tetap Laki-laki') {
                            _filterResult['statusKontrak']
                                ['pekerjaHarianTidakTetapLaki'] = true;
                            setState(() {
                              _tmpStatusKontrak = value;
                            });
                          } else if (value ==
                              'Pekerja Harian Tidak Tetap Perempuan') {
                            _filterResult['statusKontrak']
                                ['pekerjaHarianTidakTetapPerempuan'] = true;
                            setState(() {
                              _tmpStatusKontrak = value;
                            });
                          }
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _statusKontrakPekerja = false;
                              _tmpStatusKontrak = null;
                              _filterResult['statusKontrak'] = {
                                'pekerjaKontrakLaki': false,
                                'pekerjaKontrakPerempuan': false,
                                'pekerjaTetapLaki': false,
                                'pekerjaTetapPerempuan': false,
                                'pekerjaHarianTetapLaki': false,
                                'pekerjaHarianTetapPerempuan': false,
                                'pekerjaHarianTidakTetapLaki': false,
                                'pekerjaHarianTidakTetapPerempuan': false,
                              };
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['bagian'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Jabatan'),
                        value: _tmpBagian,
                        items: _listBagian.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterResult['bagian'] = value;
                          setState(() {
                            _tmpBagian = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _tmpBagian = null;
                              _filterResult['bagian'] = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['klasifikasiGaji'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Klasifikasi Gaji'),
                        value: _tmpKlasifikasiGaji,
                        items: _listKlasifikasiGaji.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterResult['klasifikasiGaji'] = value;
                          setState(() {
                            _tmpKlasifikasiGaji = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _tmpKlasifikasiGaji = null;
                              _filterResult['klasifikasiGaji'] = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 17.0),
                        child: Icon(
                          _listKategoriIcon['perusahaan'],
                          color: Colors.grey,
                        ),
                      ),
                      DropdownButton(
                        hint: Text('Cari Perusahaan'),
                        value: _tmpPerusahaan,
                        items: _listPerusahaan.map((e) {
                          return DropdownMenuItem(
                            child: Text(e),
                            value: e,
                          );
                        }).toList(),
                        onChanged: (value) {
                          _filterResult['perusahaan'] = value;
                          setState(() {
                            _tmpPerusahaan = value;
                          });
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 17.0),
                        child: IconButton(
                          icon: Icon(Icons.clear),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _tmpPerusahaan = null;
                              _filterResult['perusahaan'] = '';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Divider(),
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['bpjsKetenagakerjaan']),
                      labelText: 'Cari Nomor BPJS Ketenagakerjaan',
                      border: InputBorder.none,
                    ),
                    onChanged: (str) {
                      _filterResult['bpjsKetenagakerjaan'] = str;
                    },
                  ),
                  TextField(
                    decoration: new InputDecoration(
                      icon: Icon(_listKategoriIcon['bpjsKesehatan']),
                      labelText: 'Cari Nomor BPJS Kesehatan',
                      border: InputBorder.none,
                    ),
                    onChanged: (str) {
                      _filterResult['bpjsKesehatan'] = str;
                    },
                  ),
                ],
              ),
            ),
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
                                          _tmpKategori == 'tglLahir'
                                              ? 1945
                                              : 1975,
                                          2025,
                                          0),
                                      decoration: new InputDecoration(
                                        icon: Icon(Icons.calendar_today),
                                        hintText:
                                            "${now.toLocal()}".split(' ')[0],
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                  Text('s.d.'),
                                  Flexible(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(left: 10.0),
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
                                      } else if (_tmpKategori ==
                                          'statusKontrak') {
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
                                            _kategori =
                                                'pekerjaKontrakPerempuan';
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
                                        } else if (_searchDBS == 'phtp' ||
                                            _searchDBS == 'PHTP' ||
                                            _searchDBS == 'Phtp') {
                                          setState(() {
                                            _kategori =
                                                'pekerjaHarianTetapPerempuan';
                                            _searchDBL = [true];
                                          });
                                        } else if (_searchDBS == 'phtl' ||
                                            _searchDBS == 'PHTL' ||
                                            _searchDBS == 'Phtl') {
                                          setState(() {
                                            _kategori =
                                                'pekerjaHarianTetapLaki';
                                            _searchDBL = [true];
                                          });
                                        } else if (_searchDBS == 'phttp' ||
                                            _searchDBS == 'PHTTP' ||
                                            _searchDBS == 'Phttp') {
                                          setState(() {
                                            _kategori =
                                                'pekerjaHarianTidakTetapPerempuan';
                                            _searchDBL = [true];
                                          });
                                        } else if (_searchDBS == 'phttl' ||
                                            _searchDBS == 'PHTTL' ||
                                            _searchDBS == 'Phttl') {
                                          setState(() {
                                            _kategori =
                                                'pekerjaHarianTidakTetapLaki';
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
                                            _stringFormater(_searchDBS,
                                                'eachFirstSecondCaps')
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
                                            _stringFormater(
                                                _searchDBS, 'firstCaps')
                                          ];
                                        });
                                      }

                                      _kategori == 'bpjsKetenagakerjaan' ||
                                              _kategori == 'bpjsKesehatan'
                                          ? FirebaseFirestore.instance
                                              .collection(
                                                  trial ? 'trialuser' : 'user')
                                              .where(_kategori,
                                                  arrayContainsAny: _searchDBL)
                                              .get()
                                              .then((value) => setState(
                                                  () => _snapshot = value))
                                          : _kategori == 'tglMasuk' ||
                                                  _kategori == 'tglKeluar' ||
                                                  _kategori == 'tglLahir'
                                              ? FirebaseFirestore.instance
                                                  .collection(trial
                                                      ? 'trialuser'
                                                      : 'user')
                                                  .where(
                                                    _kategori,
                                                    isGreaterThanOrEqualTo:
                                                        Timestamp.fromDate(
                                                      filter.subtract(
                                                        Duration(
                                                            hours: filter.hour,
                                                            minutes:
                                                                filter.minute,
                                                            seconds:
                                                                filter.second),
                                                      ),
                                                    ),
                                                    isLessThanOrEqualTo:
                                                        Timestamp.fromDate(
                                                      filter1.add(
                                                        Duration(
                                                            hours: 23 -
                                                                filter1.hour,
                                                            minutes: 59 -
                                                                filter1.minute,
                                                            seconds: 59 -
                                                                filter1.second),
                                                      ),
                                                    ),
                                                  )
                                                  .get()
                                                  .then((value) => setState(
                                                      () => _snapshot = value))
                                              : FirebaseFirestore.instance
                                                  .collection(trial
                                                      ? 'trialuser'
                                                      : 'user')
                                                  .where(_kategori,
                                                      whereIn: _searchDBL)
                                                  .get()
                                                  .then((value) =>
                                                      setState(() => _snapshot = value));
                                    },
                                  ),
                                ),
                              ),
                            ),
                      Padding(
                          padding:
                              const EdgeInsets.only(top: 25.0, bottom: 90.0),
                          child: _snapshot == null
                              ? Container(
                                  padding: EdgeInsets.only(top: 30.0),
                                  child: Center(
                                    child: SpinKitChasingDots(
                                      duration:
                                          const Duration(milliseconds: 1000),
                                      color: Colors.deepPurple,
                                      size: 70.0,
                                    ),
                                  ),
                                )
                              : _buildTable())
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
