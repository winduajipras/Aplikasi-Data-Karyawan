import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:network_state/network_state.dart';

class EditKaryawan extends StatefulWidget {
  final bool trial;
  final Map document;
  final DocumentReference reference;
  final DateTime rangeKehadiran;
  final DateTime rangeKehadiran1;
  final DateTime tglMasaKerja;
  final QuerySnapshot lokasiSnapshot;
  final QuerySnapshot jabatanSnapshot;
  final QuerySnapshot perusahaanSnapshot;
  EditKaryawan(
      {this.trial,
      this.document,
      this.reference,
      this.rangeKehadiran,
      this.rangeKehadiran1,
      this.tglMasaKerja,
      this.lokasiSnapshot,
      this.jabatanSnapshot,
      this.perusahaanSnapshot});
  @override
  _EditKaryawanState createState() => _EditKaryawanState();
}

class _EditKaryawanState extends State<EditKaryawan> {
  bool trial;
  bool _addKehadiran = false;
  String _nama;
  String _nik;
  String _ktp;
  String _lokasi;
  String _alamat;
  String _tempatLahir;
  String _pendidikan;
  String _golonganDarah;
  String _kelamin;
  String _status;
  String _ibuKandung;
  String _aktif;
  String _bagian;
  String _klasifikasiGaji;
  String _perusahaan;
  String _idBpjsKetenagakerjaan;
  String _idBpjsKesehatan;
  String _kategoriIzin;
  String _keterangan = '';
  String _tmpKlasifikasiGaji;
  String _tmpPendidikan;
  String _tmpKelamin;
  String _tmpGolonganDarah;
  String _tmpLokasi;
  String _tmpStatus;
  String _tmpAktif;
  String _tmpStatusKontrak;
  String _tmpBagian;
  String _tmpPerusahaan;
  String _tmpKtp;
  String _tmpKategoriIzin;
  int _anakLaki;
  int _anakPerempuan;
  List<double> columnSize = [220.0, 160.0, 290.0, 110.0];
  List<String> dataGet = [
    'tanggalVakum',
    'kategori',
    'keterangan',
  ];
  List<String> headerTabel = [
    'Tanggal Tidak Masuk',
    'Kategori',
    'Keterangan',
    'Action',
  ];
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
  ];
  List _listKlasifikasiGaji = [
    'HARIAN',
    'MINGGUAN',
    'BULANAN',
  ];
  List _listKategoriIzin = [
    'Sakit',
    'Cuti',
    'Izin Dipotong',
    'Izin Tidak Dipotong',
  ];
  List _listDBStatusKontrak = [false, false, false, false];
  List _tmpListKehadiran = [];
  List _listKehadiran = [];
  List _listLokasi = [];
  List _listJabatan = [];
  List _listPerusahaan = [];
  DateTime _tglLahir = DateTime(
      DateTime.now().year - 18, DateTime.now().month, DateTime.now().day);
  DateTime _tglMasuk = DateTime.now();
  DateTime _tglKeluar;
  DateTime _tglMasukBpjsKetenagakerjaan;
  DateTime _tglKeluarBpjsKetenagakerjaan;
  DateTime _tglMasukBpjsKesehatan;
  DateTime _tglKeluarBpjsKesehatan;
  DateTime _tglKehadiran = DateTime.now();
  bool kirim = true;
  bool _isLoading = false;

  TextEditingController controllerNama;
  TextEditingController controllerNik;
  TextEditingController controllerKtp;
  TextEditingController controllerAlamat;
  TextEditingController controllerTempatLahir;
  TextEditingController controllerAnakLaki;
  TextEditingController controllerAnakPerempuan;
  TextEditingController controllerIbuKandung;
  TextEditingController controllerIdBpjsKetenagakerjaan;
  TextEditingController controllerIdBpjsKesehatan;

  void updateData() {
    List _tmpAddListKehadiran = [];
    _tmpListKehadiran.forEach((element) {
      bool contain = false;
      _listKehadiran.forEach((elements) {
        if (element['tanggalVakum'] == elements['tanggalVakum']) {
          contain = true;
        }
      });
      if (!contain) {
        _tmpAddListKehadiran.add(element);
      }
    });

    for (var i = 0; i < _listKehadiran.length; i++) {
      if (_listKehadiran[i]['tanggalVakum'].seconds >=
              Timestamp.fromDate(
                widget.rangeKehadiran.subtract(
                  Duration(
                      hours: widget.rangeKehadiran.hour,
                      minutes: widget.rangeKehadiran.minute,
                      seconds: widget.rangeKehadiran.second),
                ),
              ).seconds &&
          _listKehadiran[i]['tanggalVakum'].seconds <=
              Timestamp.fromDate(
                widget.rangeKehadiran1.add(
                  Duration(
                      hours: 23 - widget.rangeKehadiran1.hour,
                      minutes: 59 - widget.rangeKehadiran1.minute,
                      seconds: 59 - widget.rangeKehadiran1.second),
                ),
              ).seconds) {
        bool contain = false;
        for (var j = 0; j < _tmpListKehadiran.length; j++) {
          if (_listKehadiran[i]['tanggalVakum'] ==
              _tmpListKehadiran[j]['tanggalVakum']) {
            contain = true;
          }
        }
        if (!contain) {
          _listKehadiran.removeAt(i);
        }
      }
    }

    _listKehadiran.addAll(_tmpAddListKehadiran);

    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.reference);
      transaction.update(snapshot.reference, {
        'nama': _nama,
        'nik': _nik,
        'ktp': _ktp,
        'lokasi': _lokasi,
        'alamat': _alamat,
        'tempatLahir': _tempatLahir,
        'tglLahir': _tglLahir,
        'tglLahirShort':
            _tglLahir.day.toString() + '-' + _tglLahir.month.toString(),
        'pendidikan': _pendidikan,
        'golonganDarah': _golonganDarah,
        'kelamin': _kelamin,
        'status': _status,
        'anakLaki': _anakLaki,
        'anakPerempuan': _anakPerempuan,
        'ibuKandung': _ibuKandung,
        'tglMasuk': _tglMasuk,
        'tglKeluar': _tglKeluar,
        'aktif': _aktif,
        'pekerjaKontrakLaki': _listDBStatusKontrak[0],
        'pekerjaKontrakPerempuan': _listDBStatusKontrak[1],
        'pekerjaTetapLaki': _listDBStatusKontrak[2],
        'pekerjaTetapPerempuan': _listDBStatusKontrak[3],
        'bagian': _bagian,
        'klasifikasiGaji': _klasifikasiGaji,
        'perusahaan': _perusahaan,
        'bpjsKetenagakerjaan': [
          _idBpjsKetenagakerjaan,
          _tglMasukBpjsKetenagakerjaan,
          _tglKeluarBpjsKetenagakerjaan
        ],
        'bpjsKesehatan': [
          _idBpjsKesehatan,
          _tglMasukBpjsKesehatan,
          _tglKeluarBpjsKesehatan
        ],
        'vakum': _listKehadiran,
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    });
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

  _selectDates(
      BuildContext context, DateTime tgl, int fyear, int lyear, int i) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: tgl, // Refer step 1
      firstDate: DateTime(fyear),
      lastDate: DateTime(lyear),
    );
    if (picked != null && picked != tgl)
      setState(() {
        if (i == 0)
          _tglLahir = picked;
        else if (i == 1)
          _tglMasuk = picked;
        else if (i == 2)
          _tglMasukBpjsKetenagakerjaan = picked;
        else if (i == 3)
          _tglKeluarBpjsKetenagakerjaan = picked;
        else if (i == 4)
          _tglMasukBpjsKesehatan = picked;
        else if (i == 5)
          _tglKeluarBpjsKesehatan = picked;
        else if (i == 6)
          _tglKeluar = picked;
        else if (i == 7) _tglKehadiran = picked;
      });
  }

  bool _checkTglKehadiran(DateTime tglKehadiran) {
    bool rt = false;
    _tmpListKehadiran.forEach((element) {
      if (DateTime.fromMillisecondsSinceEpoch(
                  element['tanggalVakum'].seconds * 1000)
              .day ==
          tglKehadiran.day) {
        rt = true;
      }
    });
    return rt;
  }

  List<Widget> _buildCells(int row) {
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
            : index == headerTabel.length - 1
                ? IconButton(
                    icon: Icon(Icons.delete, color: Colors.deepPurple),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          String alertText =
                              "Apakah anda yakin menghapus data kehadiran ini?";
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
                                    setState(() =>
                                        _tmpListKehadiran.removeAt(row - 1));
                                    Navigator.of(context).pop(false);
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
                  )
                : Text(
                    index == 0
                        ? _getFormatedDate(
                            _tmpListKehadiran[row - 1][dataGet[index]])
                        : _tmpListKehadiran[row - 1][dataGet[index]],
                    textAlign: TextAlign.center,
                    style:
                        new TextStyle(fontSize: 15.0, color: Colors.deepPurple),
                  ),
      ),
    );
  }

  List<Widget> _buildRows(List document) {
    return List.generate(
      document.length + 1,
      (index) => Row(
        children: _buildCells(index),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    trial = widget.trial;
    controllerNama = TextEditingController(text: widget.document['nama']);
    controllerNik = TextEditingController(text: widget.document['nik']);
    controllerKtp = TextEditingController(text: widget.document['ktp']);
    controllerAlamat = TextEditingController(text: widget.document['alamat']);
    controllerTempatLahir =
        TextEditingController(text: widget.document['tempatLahir']);
    controllerAnakLaki =
        TextEditingController(text: widget.document['anakLaki'].toString());
    controllerAnakPerempuan = TextEditingController(
        text: widget.document['anakPerempuan'].toString());
    controllerIbuKandung =
        TextEditingController(text: widget.document['ibuKandung']);
    controllerIdBpjsKetenagakerjaan =
        TextEditingController(text: widget.document['bpjsKetenagakerjaan'][0]);
    controllerIdBpjsKesehatan =
        TextEditingController(text: widget.document['bpjsKesehatan'][0]);
    _nama = widget.document['nama'];
    _nik = widget.document['nik'];
    _ktp = widget.document['ktp'];
    _lokasi = widget.document['lokasi'];
    _alamat = widget.document['alamat'];
    _tempatLahir = widget.document['tempatLahir'];
    _tglLahir = DateTime.fromMillisecondsSinceEpoch(
        widget.document['tglLahir'].seconds * 1000);
    _pendidikan = widget.document['pendidikan'];
    _golonganDarah = widget.document['golonganDarah'];
    _kelamin = widget.document['kelamin'];
    _status = widget.document['status'];
    _anakLaki = widget.document['anakLaki'];
    _anakPerempuan = widget.document['anakPerempuan'];
    _ibuKandung = widget.document['ibuKandung'];
    _tglMasuk = widget.document['tglMasuk'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            widget.document['tglMasuk'].seconds * 1000);
    _tglKeluar = widget.document['tglKeluar'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            widget.document['tglKeluar'].seconds * 1000);
    _aktif = widget.document['aktif'];
    _bagian = widget.document['bagian'];
    _klasifikasiGaji = widget.document['klasifikasiGaji'];
    _perusahaan = widget.document['perusahaan'];
    _idBpjsKetenagakerjaan = widget.document['bpjsKetenagakerjaan'][0];
    _tglMasukBpjsKetenagakerjaan =
        widget.document['bpjsKetenagakerjaan'][1] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                widget.document['bpjsKetenagakerjaan'][1].seconds * 1000);
    _tglKeluarBpjsKetenagakerjaan =
        widget.document['bpjsKetenagakerjaan'][2] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(
                widget.document['bpjsKetenagakerjaan'][2].seconds * 1000);
    _idBpjsKesehatan = widget.document['bpjsKesehatan'][0];
    _tglMasukBpjsKesehatan = widget.document['bpjsKesehatan'][1] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            widget.document['bpjsKesehatan'][1].seconds * 1000);
    _tglKeluarBpjsKesehatan = widget.document['bpjsKesehatan'][2] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(
            widget.document['bpjsKesehatan'][2].seconds * 1000);

    if (widget.document['vakum'] != null) {
      _listKehadiran = widget.document['vakum'];
      widget.document['vakum'].forEach((element) {
        if (element['tanggalVakum'].seconds >=
                Timestamp.fromDate(
                  widget.rangeKehadiran.subtract(
                    Duration(
                        hours: widget.rangeKehadiran.hour,
                        minutes: widget.rangeKehadiran.minute,
                        seconds: widget.rangeKehadiran.second),
                  ),
                ).seconds &&
            element['tanggalVakum'].seconds <=
                Timestamp.fromDate(
                  widget.rangeKehadiran1.add(
                    Duration(
                        hours: 23 - widget.rangeKehadiran1.hour,
                        minutes: 59 - widget.rangeKehadiran1.minute,
                        seconds: 59 - widget.rangeKehadiran1.second),
                  ),
                ).seconds) {
          _tmpListKehadiran.add(element);
        }
      });
    }

    if (widget.document['lokasi'] != '') _tmpLokasi = widget.document['lokasi'];
    if (widget.document['pendidikan'] != '')
      _tmpPendidikan = widget.document['pendidikan'];
    if (widget.document['golonganDarah'] != '')
      _tmpGolonganDarah = widget.document['golonganDarah'];
    if (widget.document['kelamin'] != '')
      _tmpKelamin = widget.document['kelamin'];
    if (widget.document['bagian'] != '') _tmpBagian = widget.document['bagian'];
    if (widget.document['klasifikasiGaji'] != '')
      _tmpKlasifikasiGaji = widget.document['klasifikasiGaji'];
    if (widget.document['perusahaan'] != '')
      _tmpPerusahaan = widget.document['perusahaan'];
    if (widget.document['ktp'] != '') _tmpKtp = widget.document['ktp'];
    if (widget.document['status'] != '') _tmpStatus = widget.document['status'];
    if (widget.document['aktif'] != '') _tmpAktif = widget.document['aktif'];

    if (widget.document['pekerjaKontrakLaki']) {
      _listDBStatusKontrak[0] = true;
      _tmpStatusKontrak = _listStatusKontrak[0];
    } else if (widget.document['pekerjaKontrakPerempuan']) {
      _listDBStatusKontrak[1] = true;
      _tmpStatusKontrak = _listStatusKontrak[1];
    } else if (widget.document['pekerjaTetapLaki']) {
      _listDBStatusKontrak[2] = true;
      _tmpStatusKontrak = _listStatusKontrak[2];
    } else if (widget.document['pekerjaTetapPerempuan']) {
      _listDBStatusKontrak[3] = true;
      _tmpStatusKontrak = _listStatusKontrak[3];
    }

    widget.lokasiSnapshot.docs.forEach((element) {
      _listLokasi.add(element.get('lokasi'));
    });
    widget.jabatanSnapshot.docs.forEach((element) {
      _listJabatan.add(element.get('jabatan'));
    });
    widget.perusahaanSnapshot.docs.forEach((element) {
      _listPerusahaan.add(element.get('perusahaan'));
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(trial ? 'trialuser' : 'user')
          .where('ktp', isEqualTo: _ktp)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Container(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          return new Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            floatingActionButton: _isLoading
                ? CircularProgressIndicator()
                : FloatingActionButton(
                    backgroundColor: Colors.deepPurple,
                    child: Icon(Icons.check),
                    onPressed: () async {
                      if (kirim) {
                        bool validate = false;
                        if (snapshot.data.docs.length > 0 && _ktp != _tmpKtp) {
                          validate = true;
                        }
                        if (!validate) {
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
                              updateData();
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
                        } else {
                          dialog(context, 'KTP sudah terdaftar');
                        }
                      } else {
                        dialog(context, 'KTP masih kosong');
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
                    Icons.playlist_add,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    _tglKehadiran = DateTime.now();
                    _kategoriIzin = null;
                    _tmpKategoriIzin = null;
                    _keterangan = '';
                    setState(() {
                      _addKehadiran = !_addKehadiran;
                    });
                  },
                ),
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
              title: new Text('Edit Data Karyawan'),
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
                        controller: controllerNik,
                        onChanged: (String str) {
                          _nik = str;
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.card_membership),
                          labelText: 'NIK',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        controller: controllerKtp,
                        onChanged: (String str) {
                          if (str == null || str == '') {
                            kirim = false;
                            _ktp = '';
                          } else {
                            kirim = true;
                            _ktp = str;
                          }
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.chrome_reader_mode),
                          labelText: 'KTP',
                          border: InputBorder.none,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17.0),
                            child: Icon(
                              Icons.location_on_rounded,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Lokasi'),
                            value: _tmpLokasi,
                            items: _listLokasi.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _lokasi = value;
                              setState(() {
                                _tmpLokasi = value;
                              });
                            },
                          ),
                        ],
                      ),
                      TextField(
                        controller: controllerAlamat,
                        onChanged: (String str) {
                          _alamat = str;
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.label_important_rounded),
                          labelText: 'Alamat',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        controller: controllerTempatLahir,
                        onChanged: (String str) {
                          _tempatLahir = str;
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.home),
                          labelText: 'Tempat Lahir',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        onTap: () =>
                            _selectDates(context, _tglLahir, 1945, 2025, 0),
                        decoration: new InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: 'Tanggal Lahir : ' +
                              "${_tglLahir.toLocal()}".split(' ')[0],
                          border: InputBorder.none,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17.0),
                            child: Icon(
                              Icons.school,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Pendidikan'),
                            value: _tmpPendidikan,
                            items: _listPendidikan.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _pendidikan = value;
                              setState(() {
                                _tmpPendidikan = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17.0),
                            child: Icon(
                              Icons.whatshot_rounded,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Golongan Darah'),
                            value: _tmpGolonganDarah,
                            items: _listGolonganDarah.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _golonganDarah = value;
                              setState(() {
                                _tmpGolonganDarah = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17.0),
                            child: Icon(
                              Icons.person_outline_sharp,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Kelamin'),
                            value: _tmpKelamin,
                            items: _listKelamin.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _kelamin = value;
                              setState(() {
                                _tmpKelamin = value;
                              });
                            },
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
                              Icons.family_restroom_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Status'),
                            value: _tmpStatus,
                            items: _listStatus.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _status = value;
                              setState(() {
                                _tmpStatus = value;
                              });
                            },
                          ),
                        ],
                      ),
                      TextField(
                        controller: controllerAnakLaki,
                        onChanged: (String str) {
                          _anakLaki = int.parse(str);
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.child_friendly),
                          labelText: 'Anak Laki-laki',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        controller: controllerAnakPerempuan,
                        onChanged: (String str) {
                          _anakPerempuan = int.parse(str);
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.child_friendly_outlined),
                          labelText: 'Anak Perempuan',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        controller: controllerIbuKandung,
                        onChanged: (String str) {
                          _ibuKandung = str;
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.pregnant_woman_rounded),
                          labelText: 'Ibu Kandung',
                          border: InputBorder.none,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Divider(),
                      ),
                      TextField(
                        readOnly: true,
                        onTap: () =>
                            _selectDates(context, _tglMasuk, 1975, 2025, 1),
                        decoration: new InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: _tglMasuk == null
                              ? 'Tanggal Masuk'
                              : 'Tanggal Masuk : ' +
                                  "${_tglMasuk.toLocal()}".split(' ')[0],
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        onTap: () => _selectDates(
                            context, DateTime.now(), 1975, 2025, 6),
                        decoration: new InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: _tglKeluar == null
                              ? 'Tanggal Keluar'
                              : 'Tanggal Keluar : ' +
                                  "${_tglKeluar.toLocal()}".split(' ')[0],
                          border: InputBorder.none,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17.0),
                            child: Icon(
                              Icons.work,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Status Kerja'),
                            value: _tmpAktif,
                            items: _listAktif.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _aktif = value;
                              setState(() {
                                _tmpAktif = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17.0),
                            child: Icon(
                              Icons.supervised_user_circle_rounded,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Status Kontrak'),
                            value: _tmpStatusKontrak,
                            items: _listStatusKontrak.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _listDBStatusKontrak = [
                                false,
                                false,
                                false,
                                false
                              ];
                              if (value == 'Pekerja Kontrak Laki-laki') {
                                _listDBStatusKontrak[0] = true;
                                setState(() {
                                  _tmpStatusKontrak = value;
                                });
                              } else if (value == 'Pekerja Kontrak Perempuan') {
                                _listDBStatusKontrak[1] = true;
                                setState(() {
                                  _tmpStatusKontrak = value;
                                });
                              } else if (value == 'Pekerja Tetap Laki-laki') {
                                _listDBStatusKontrak[2] = true;
                                setState(() {
                                  _tmpStatusKontrak = value;
                                });
                              } else if (value == 'Pekerja Tetap Perempuan') {
                                _listDBStatusKontrak[3] = true;
                                setState(() {
                                  _tmpStatusKontrak = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17.0),
                            child: Icon(
                              Icons.label,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Jabatan'),
                            value: _tmpBagian,
                            items: _listJabatan.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _bagian = value;
                              setState(() {
                                _tmpBagian = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17.0),
                            child: Icon(
                              Icons.monetization_on_rounded,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Klasifikasi Gaji'),
                            value: _tmpKlasifikasiGaji,
                            items: _listKlasifikasiGaji.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _klasifikasiGaji = value;
                              setState(() {
                                _tmpKlasifikasiGaji = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 17.0),
                            child: Icon(
                              Icons.location_city,
                              color: Colors.grey,
                            ),
                          ),
                          DropdownButton(
                            hint: Text('Perusahaan'),
                            value: _tmpPerusahaan,
                            items: _listPerusahaan.map((e) {
                              return DropdownMenuItem(
                                child: Text(e),
                                value: e,
                              );
                            }).toList(),
                            onChanged: (value) {
                              _perusahaan = value;
                              setState(() {
                                _tmpPerusahaan = value;
                              });
                            },
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Divider(),
                      ),
                      TextField(
                        controller: controllerIdBpjsKetenagakerjaan,
                        onChanged: (String str) {
                          _idBpjsKetenagakerjaan = str;
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.home_repair_service),
                          labelText: 'BPJS Ketenagakerjaan',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        onTap: () => _selectDates(
                            context, DateTime.now(), 1975, 2025, 2),
                        decoration: new InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: _tglMasukBpjsKetenagakerjaan == null
                              ? 'Tanggal Gabung'
                              : 'Tanggal Gabung : ' +
                                  "${_tglMasukBpjsKetenagakerjaan.toLocal()}"
                                      .split(' ')[0],
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        onTap: () => _selectDates(
                            context, DateTime.now(), 1975, 2025, 3),
                        decoration: new InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: _tglKeluarBpjsKetenagakerjaan == null
                              ? 'Tanggal Keluar'
                              : 'Tanggal Keluar : ' +
                                  "${_tglKeluarBpjsKetenagakerjaan.toLocal()}"
                                      .split(' ')[0],
                          border: InputBorder.none,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Divider(),
                      ),
                      TextField(
                        controller: controllerIdBpjsKesehatan,
                        onChanged: (String str) {
                          _idBpjsKesehatan = str;
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.local_hospital),
                          labelText: 'BPJS Kesehatan',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        onTap: () => _selectDates(
                            context, DateTime.now(), 1975, 2025, 4),
                        decoration: new InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: _tglMasukBpjsKesehatan == null
                              ? 'Tanggal Gabung'
                              : 'Tanggal Gabung : ' +
                                  "${_tglMasukBpjsKesehatan.toLocal()}"
                                      .split(' ')[0],
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        readOnly: true,
                        onTap: () => _selectDates(
                            context, DateTime.now(), 1975, 2025, 5),
                        decoration: new InputDecoration(
                          icon: Icon(Icons.calendar_today),
                          hintText: _tglKeluarBpjsKesehatan == null
                              ? 'Tanggal Keluar'
                              : 'Tanggal Keluar : ' +
                                  "${_tglKeluarBpjsKesehatan.toLocal()}"
                                      .split(' ')[0],
                          border: InputBorder.none,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Divider(),
                      ),
                      _addKehadiran
                          ? Container(
                              child: Column(
                                children: [
                                  TextField(
                                    readOnly: true,
                                    onTap: () => _selectDates(context,
                                        widget.tglMasaKerja, 1975, 2025, 7),
                                    decoration: new InputDecoration(
                                      icon: Icon(Icons.calendar_today),
                                      hintText: _tglKehadiran == null
                                          ? 'Tanggal Tidak Masuk'
                                          : 'Tanggal Tidak Masuk : ' +
                                              "${_tglKehadiran.toLocal()}"
                                                  .split(' ')[0],
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
                                        child: Icon(
                                          Icons.drafts_sharp,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      DropdownButton(
                                        hint: Text('Kategori'),
                                        value: _tmpKategoriIzin,
                                        items: _listKategoriIzin.map((e) {
                                          return DropdownMenuItem(
                                            child: Text(e),
                                            value: e,
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          _kategoriIzin = value;
                                          setState(() {
                                            _tmpKategoriIzin = value;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  TextField(
                                    onChanged: (String str) {
                                      _keterangan = str;
                                    },
                                    decoration: new InputDecoration(
                                      icon: Icon(Icons.contact_page_rounded),
                                      labelText: 'Keterangan',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: _tglKehadiran != null &&
                                                  _kategoriIzin != null &&
                                                  !_checkTglKehadiran(
                                                      _tglKehadiran)
                                              ? () {
                                                  _tmpListKehadiran.add({
                                                    'tanggalVakum':
                                                        Timestamp.fromDate(
                                                            _tglKehadiran),
                                                    'kategori': _kategoriIzin,
                                                    'keterangan': _keterangan,
                                                  });
                                                  setState(() {
                                                    _addKehadiran = false;
                                                  });
                                                }
                                              : null,
                                          child: Text('Add'),
                                        ),
                                        SizedBox(
                                          width: 45.0,
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            // _tglKehadiran = null;
                                            _kategoriIzin = null;
                                            _tmpKategoriIzin = null;
                                            _keterangan = '';
                                            setState(() {
                                              _addKehadiran = false;
                                            });
                                          },
                                          child: Text('Cancel'),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(bottom: 30.0),
                              child: Container(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: _buildRows(_tmpListKehadiran),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
