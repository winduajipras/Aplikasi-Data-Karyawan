import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:jia/common_widgets/alert_dialog.dart';
import 'package:network_state/network_state.dart';

class AddKaryawan extends StatefulWidget {
  final bool trial;
  final QuerySnapshot lokasiSnapshot;
  final QuerySnapshot jabatanSnapshot;
  final QuerySnapshot perusahaanSnapshot;
  AddKaryawan(
      {this.trial,
      this.lokasiSnapshot,
      this.jabatanSnapshot,
      this.perusahaanSnapshot});
  @override
  _AddKaryawanState createState() => _AddKaryawanState();
}

class _AddKaryawanState extends State<AddKaryawan> {
  String _nama = '';
  String _nik = '';
  String _ktp = '';
  String _lokasi = '';
  String _alamat = '';
  String _tempatLahir = '';
  String _pendidikan = '';
  String _sekolah = '';
  String _jurusan = '';
  String _golonganDarah = '';
  String _kelamin = '';
  String _status = '';
  String _ibuKandung = '';
  String _aktif = '';
  String _bagian = '';
  String _klasifikasiGaji = '';
  String _perusahaan = '';
  String _idBpjsKetenagakerjaan = '';
  String _idBpjsKesehatan = '';
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
  int _anakLaki = 0;
  int _anakPerempuan = 0;
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
  List _listKlasifikasiGaji = [
    'HARIAN',
    'MINGGUAN',
    'BULANAN',
  ];
  List _listDBStatusKontrak = [
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false
  ];
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
  bool kirim = false;
  bool _isLoading = false;

  void addData() {
    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      CollectionReference reference = FirebaseFirestore.instance
          .collection(widget.trial ? 'trialuser' : 'user');
      await reference.add({
        'nama': _nama,
        'nik': _nik,
        'ktp': _ktp,
        'lokasi': _lokasi,
        'alamat': _alamat,
        'tempatLahir': _stringFormater(_tempatLahir),
        'tglLahir': _tglLahir,
        'tglLahirShort':
            _tglLahir.day.toString() + '-' + _tglLahir.month.toString(),
        'pendidikan': _pendidikan,
        'sekolah': _sekolah,
        'jurusan': _stringFormater(_jurusan),
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
        'pekerjaHarianTetapLaki': _listDBStatusKontrak[4],
        'pekerjaHarianTetapPerempuan': _listDBStatusKontrak[5],
        'pekerjaHarianTidakTetapLaki': _listDBStatusKontrak[6],
        'pekerjaHarianTidakTetapPerempuan': _listDBStatusKontrak[7],
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
        'vakum': null,
        'riwayatPendidikan': [],
        'pengalamanKerja': [],
        'riwayatJabatan': [],
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    });
  }

  _stringFormater(String text) {
    if (text == '') return '';
    List<String> split = text.split(' ');
    List<String> convert = [];
    split.forEach((element) {
      if (element.length > 0) {
        convert.add(
            '${element[0].toUpperCase()}${element.substring(1).toLowerCase()}');
      }
    });
    String hasil = convert.join(' ');
    return hasil;
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
        else if (i == 6) _tglKeluar = picked;
      });
  }

  @override
  void initState() {
    super.initState();
    widget.lokasiSnapshot.docs.forEach((element) {
      if (element.get('perusahaan').contains(_perusahaan)) {
        _listLokasi.add(element.get('lokasi'));
      }
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
          .collection(widget.trial ? 'trialuser' : 'user')
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
                        if (snapshot.data.docs.length > 0) {
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
              title: new Text('Tambah Data Karyawan'),
            ),
            body: new Container(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (String str) {
                          _nama = str.toUpperCase();
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.person),
                          labelText: 'Nama Lengkap',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        onChanged: (String str) {
                          _nik = str.toUpperCase();
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.card_membership),
                          labelText: 'NIK',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        onChanged: (String str) {
                          if (str == null || str == '') {
                            setState(() {
                              kirim = false;
                              _ktp = '';
                            });
                          } else {
                            setState(() {
                              kirim = true;
                              _ktp = str;
                            });
                          }
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.chrome_reader_mode),
                          labelText: 'KTP',
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      TextField(
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
                            hint: Text('Pendidikan Terakhir'),
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
                      TextField(
                        onChanged: (String str) {
                          _sekolah = str.toUpperCase();
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.local_library),
                          labelText: 'Nama Sekolah',
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        onChanged: (String str) {
                          _jurusan = str;
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.explore),
                          labelText: 'Jurusan',
                          border: InputBorder.none,
                        ),
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
                            hint: Text('Jenis Kelamin'),
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
                            hint: Text('Status Perkawinan'),
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
                        onChanged: (String str) {
                          _anakLaki = int.parse(str);
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.child_friendly),
                          labelText: 'Jumlah Anak Laki-laki',
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      TextField(
                        onChanged: (String str) {
                          _anakPerempuan = int.parse(str);
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.child_friendly_outlined),
                          labelText: 'Jumlah Anak Perempuan',
                          border: InputBorder.none,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                      ),
                      TextField(
                        onChanged: (String str) {
                          _ibuKandung = str.toUpperCase();
                        },
                        decoration: new InputDecoration(
                          icon: Icon(Icons.pregnant_woman_rounded),
                          labelText: 'Nama Ibu Kandung',
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
                            hint: Text('Status Pekerja'),
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
                                false,
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
                              } else if (value ==
                                  'Pekerja Harian Tetap Laki-laki') {
                                _listDBStatusKontrak[4] = true;
                                setState(() {
                                  _tmpStatusKontrak = value;
                                });
                              } else if (value ==
                                  'Pekerja Harian Tetap Perempuan') {
                                _listDBStatusKontrak[5] = true;
                                setState(() {
                                  _tmpStatusKontrak = value;
                                });
                              } else if (value ==
                                  'Pekerja Harian Tidak Tetap Laki-laki') {
                                _listDBStatusKontrak[6] = true;
                                setState(() {
                                  _tmpStatusKontrak = value;
                                });
                              } else if (value ==
                                  'Pekerja Harian Tidak Tetap Perempuan') {
                                _listDBStatusKontrak[7] = true;
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
                                _listLokasi = [];
                                _tmpLokasi = null;
                                _lokasi = '';
                                widget.lokasiSnapshot.docs.forEach((element) {
                                  if (element
                                      .get('perusahaan')
                                      .contains(value)) {
                                    _listLokasi.add(element.get('lokasi'));
                                  }
                                });
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
                      Padding(
                        padding: const EdgeInsets.all(30.0),
                        child: Divider(),
                      ),
                      TextField(
                        onChanged: (String str) {
                          _idBpjsKetenagakerjaan = str.toUpperCase();
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
                        onChanged: (String str) {
                          _idBpjsKesehatan = str.toUpperCase();
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
