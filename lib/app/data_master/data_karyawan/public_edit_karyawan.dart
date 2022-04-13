import 'dart:async';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
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
  String _page = 'biodata';
  String _nama;
  String _nik;
  String _ktp;
  String _lokasi;
  String _alamat;
  String _tempatLahir;
  String _pendidikan;
  String _sekolah;
  String _jurusan;
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
  String _avatarUrl;
  int _anakLaki;
  int _anakPerempuan;
  List _riwayatPendidikan = [];
  List _pengalamanKerja = [];
  List _riwayatJabatan = [];
  Map<String, int> textFieldCount = {};
  // List<double> columnSize = [220.0, 160.0, 290.0, 110.0];
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
  bool kirim = true;
  bool _isLoading = false;

  TextEditingController controllerNama;
  TextEditingController controllerNik;
  TextEditingController controllerKtp;
  TextEditingController controllerAlamat;
  TextEditingController controllerTempatLahir;
  TextEditingController controllerSekolah;
  TextEditingController controllerJurusan;
  TextEditingController controllerAnakLaki;
  TextEditingController controllerAnakPerempuan;
  TextEditingController controllerIbuKandung;
  TextEditingController controllerIdBpjsKetenagakerjaan;
  TextEditingController controllerIdBpjsKesehatan;
  List<TextEditingController> controllerRiwayatPendidikan = [];
  List<TextEditingController> controllerPengalamanKerja = [];
  List<TextEditingController> controllerRiwayatJabatan = [];

  final picker = ImagePicker();

  Future picked() async {
    Uint8List imageFile =
        await ImagePickerWeb.getImage(outputType: ImageType.bytes);
    if (imageFile != null) {
      setState(() {
        _isLoading = true;
      });
      uploadProfilePhotoToFirebase(imageFile);
    }
  }

  Future uploadProfilePhotoToFirebase(Uint8List _image) async {
    String trialUser = trial ? 'trialuser' : 'user';
    Reference firebaseStorageRef = FirebaseStorage.instance
        .ref()
        .child('$trialUser/${widget.reference.id}/avatar.jpg');
    TaskSnapshot uploadTask = await firebaseStorageRef.putData(
        _image, SettableMetadata(contentType: 'image/jpg'));
    String url = await uploadTask.ref.getDownloadURL(); //Get URL
    return await FirebaseFirestore.instance
        .runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.reference);
      transaction.update(snapshot.reference, {
        'avatar': url,
      });
    }).whenComplete(() {
      setState(() {
        _isLoading = false;
        _avatarUrl = url;
      });
    });
  }

  void updateData(BuildContext context) {
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

    _riwayatPendidikan.removeWhere((element) => element.length == 0);
    _riwayatPendidikan.join(', ');

    _pengalamanKerja.removeWhere((element) => element.length == 0);
    _pengalamanKerja.join(', ');

    _riwayatJabatan.removeWhere((element) => element.length == 0);
    _riwayatJabatan.join(', ');

    FirebaseFirestore.instance.runTransaction((Transaction transaction) async {
      DocumentSnapshot snapshot = await transaction.get(widget.reference);
      transaction.update(snapshot.reference, {
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
        'vakum': _listKehadiran,
        'riwayatPendidikan': _riwayatPendidikan,
        'pengalamanKerja': _pengalamanKerja,
        'riwayatJabatan': _riwayatJabatan,
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

  List<Widget> _buildTextField(
      List _str, List<TextEditingController> textController, int i, Icon ikon) {
    return List.generate(
      i,
      (index) => TextField(
        controller: textController[index],
        onChanged: (String str) {
          _str[index] = str;
        },
        decoration: new InputDecoration(
          icon: ikon,
          border: InputBorder.none,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    trial = widget.trial;
    _avatarUrl = widget.document['avatar'];

    //controller
    controllerNama = TextEditingController(text: widget.document['nama']);
    controllerNik = TextEditingController(text: widget.document['nik']);
    controllerKtp = TextEditingController(text: widget.document['ktp']);
    controllerAlamat = TextEditingController(text: widget.document['alamat']);
    controllerTempatLahir =
        TextEditingController(text: widget.document['tempatLahir']);
    controllerSekolah = TextEditingController(text: widget.document['sekolah']);
    controllerJurusan = TextEditingController(text: widget.document['jurusan']);
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
    widget.document['riwayatPendidikan'].forEach((element) {
      controllerRiwayatPendidikan.add(TextEditingController(text: element));
    });
    widget.document['pengalamanKerja'].forEach((element) {
      controllerPengalamanKerja.add(TextEditingController(text: element));
    });
    widget.document['riwayatJabatan'].forEach((element) {
      controllerRiwayatJabatan.add(TextEditingController(text: element));
    });

    textFieldCount.addAll({
      'riwayatPendidikan': widget.document['riwayatPendidikan'].length,
      'pengalamanKerja': widget.document['pengalamanKerja'].length,
      'riwayatJabatan': widget.document['riwayatJabatan'].length
    });

    _nama = widget.document['nama'];
    _nik = widget.document['nik'];
    _ktp = widget.document['ktp'];
    _lokasi = widget.document['lokasi'];
    _alamat = widget.document['alamat'];
    _tempatLahir = widget.document['tempatLahir'];
    _tglLahir = DateTime.fromMillisecondsSinceEpoch(
        widget.document['tglLahir'].seconds * 1000);
    _pendidikan = widget.document['pendidikan'];
    _sekolah = widget.document['sekolah'];
    _jurusan = widget.document['jurusan'];
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
    _riwayatPendidikan = widget.document['riwayatPendidikan'];
    _pengalamanKerja = widget.document['pengalamanKerja'];
    _riwayatJabatan = widget.document['riwayatJabatan'];

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
    } else if (widget.document['pekerjaHarianTetapLaki']) {
      _listDBStatusKontrak[4] = true;
      _tmpStatusKontrak = _listStatusKontrak[4];
    } else if (widget.document['pekerjaHarianTetapPerempuan']) {
      _listDBStatusKontrak[5] = true;
      _tmpStatusKontrak = _listStatusKontrak[5];
    } else if (widget.document['pekerjaHarianTidakTetapLaki']) {
      _listDBStatusKontrak[6] = true;
      _tmpStatusKontrak = _listStatusKontrak[6];
    } else if (widget.document['pekerjaHarianTidakTetapPerempuan']) {
      _listDBStatusKontrak[7] = true;
      _tmpStatusKontrak = _listStatusKontrak[7];
    }

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
                              updateData(context);
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
                    Icons.list_alt,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _page = 'histori';
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.contact_page,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _page = 'biodata';
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
                      Container(
                        child: _isLoading
                            ? CircularProgressIndicator()
                            : InkWell(
                                onTap: () => picked(),
                                child: CircleAvatar(
                                  radius: 50.0,
                                  backgroundColor: Colors.black12,
                                  backgroundImage: _avatarUrl != null
                                      ? NetworkImage(_avatarUrl)
                                      : null,
                                  child: _avatarUrl == null
                                      ? Icon(Icons.camera_alt, size: 50.0)
                                      : null,
                                ),
                              ),
                      ),
                      _page == 'biodata'
                          ? Container(
                              child: Column(
                                children: [
                                  TextField(
                                    controller: controllerNama,
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
                                    controller: controllerNik,
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
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
                                    onTap: () => _selectDates(
                                        context, _tglLahir, 1945, 2025, 0),
                                    decoration: new InputDecoration(
                                      icon: Icon(Icons.calendar_today),
                                      hintText: 'Tanggal Lahir : ' +
                                          "${_tglLahir.toLocal()}"
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
                                    controller: controllerSekolah,
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
                                    controller: controllerJurusan,
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
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
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
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
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
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
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
                                      labelText: 'Jumlah Anak Laki-laki',
                                      border: InputBorder.none,
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                  ),
                                  TextField(
                                    controller: controllerAnakPerempuan,
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
                                    controller: controllerIbuKandung,
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
                                    onTap: () => _selectDates(
                                        context, _tglMasuk, 1975, 2025, 1),
                                    decoration: new InputDecoration(
                                      icon: Icon(Icons.calendar_today),
                                      hintText: _tglMasuk == null
                                          ? 'Tanggal Masuk'
                                          : 'Tanggal Masuk : ' +
                                              "${_tglMasuk.toLocal()}"
                                                  .split(' ')[0],
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
                                              "${_tglKeluar.toLocal()}"
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
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
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
                                          if (value ==
                                              'Pekerja Kontrak Laki-laki') {
                                            _listDBStatusKontrak[0] = true;
                                            setState(() {
                                              _tmpStatusKontrak = value;
                                            });
                                          } else if (value ==
                                              'Pekerja Kontrak Perempuan') {
                                            _listDBStatusKontrak[1] = true;
                                            setState(() {
                                              _tmpStatusKontrak = value;
                                            });
                                          } else if (value ==
                                              'Pekerja Tetap Laki-laki') {
                                            _listDBStatusKontrak[2] = true;
                                            setState(() {
                                              _tmpStatusKontrak = value;
                                            });
                                          } else if (value ==
                                              'Pekerja Tetap Perempuan') {
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
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
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
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
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
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
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
                                            widget.lokasiSnapshot.docs
                                                .forEach((element) {
                                              if (element
                                                  .get('perusahaan')
                                                  .contains(value)) {
                                                _listLokasi
                                                    .add(element.get('lokasi'));
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
                                        padding:
                                            const EdgeInsets.only(right: 17.0),
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
                                    controller: controllerIdBpjsKetenagakerjaan,
                                    onChanged: (String str) {
                                      _idBpjsKetenagakerjaan =
                                          str.toUpperCase();
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
                                      hintText: _tglMasukBpjsKetenagakerjaan ==
                                              null
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
                                      hintText: _tglKeluarBpjsKetenagakerjaan ==
                                              null
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
                                  Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Divider(),
                                  ),
                                ],
                              ),
                            )
                          : Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // riwayat pendidikan
                                  Row(
                                    children: [
                                      Text(
                                        'Riwayat Pendidikan',
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.black54),
                                      ),
                                      Expanded(child: new SizedBox()),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            textFieldCount.update(
                                                'riwayatPendidikan',
                                                (value) => value = value + 1);
                                            _riwayatPendidikan.add('');
                                            controllerRiwayatPendidikan.add(
                                                TextEditingController(
                                                    text: ''));
                                          });
                                        },
                                        icon: Icon(Icons.add,
                                            color: Colors.deepPurple),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_riwayatPendidikan.length > 0) {
                                              textFieldCount.update(
                                                  'riwayatPendidikan',
                                                  (value) => value = value - 1);
                                              _riwayatPendidikan.removeLast();
                                              controllerRiwayatPendidikan
                                                  .removeLast();
                                            }
                                          });
                                        },
                                        icon: Icon(Icons.remove,
                                            color: Colors.deepOrange),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: _buildTextField(
                                        _riwayatPendidikan,
                                        controllerRiwayatPendidikan,
                                        textFieldCount['riwayatPendidikan'],
                                        Icon(Icons.school)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Divider(),
                                  ),
                                  // pengalaman kerja
                                  Row(
                                    children: [
                                      Text(
                                        'Pengalaman Kerja',
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.black54),
                                      ),
                                      Expanded(child: new SizedBox()),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            textFieldCount.update(
                                                'pengalamanKerja',
                                                (value) => value = value + 1);
                                            _pengalamanKerja.add('');
                                            controllerPengalamanKerja.add(
                                                TextEditingController(
                                                    text: ''));
                                          });
                                        },
                                        icon: Icon(Icons.add,
                                            color: Colors.deepPurple),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_pengalamanKerja.length > 0) {
                                              textFieldCount.update(
                                                  'pengalamanKerja',
                                                  (value) => value = value - 1);
                                              _pengalamanKerja.removeLast();
                                              controllerPengalamanKerja
                                                  .removeLast();
                                            }
                                          });
                                        },
                                        icon: Icon(Icons.remove,
                                            color: Colors.deepOrange),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: _buildTextField(
                                        _pengalamanKerja,
                                        controllerPengalamanKerja,
                                        textFieldCount['pengalamanKerja'],
                                        Icon(Icons.work)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(30.0),
                                    child: Divider(),
                                  ),
                                  // riwayat jabatan
                                  Row(
                                    children: [
                                      Text(
                                        'Riwayat Jabatan',
                                        style: TextStyle(
                                            fontSize: 17.0,
                                            color: Colors.black54),
                                      ),
                                      Expanded(child: new SizedBox()),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            textFieldCount.update(
                                                'riwayatJabatan',
                                                (value) => value = value + 1);
                                            _riwayatJabatan.add('');
                                            controllerRiwayatJabatan.add(
                                                TextEditingController(
                                                    text: ''));
                                          });
                                        },
                                        icon: Icon(Icons.add,
                                            color: Colors.deepPurple),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          setState(() {
                                            if (_riwayatJabatan.length > 0) {
                                              textFieldCount.update(
                                                  'riwayatJabatan',
                                                  (value) => value = value - 1);
                                              _riwayatJabatan.removeLast();
                                              controllerRiwayatJabatan
                                                  .removeLast();
                                            }
                                          });
                                        },
                                        icon: Icon(Icons.remove,
                                            color: Colors.deepOrange),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: _buildTextField(
                                        _riwayatJabatan,
                                        controllerRiwayatJabatan,
                                        textFieldCount['riwayatJabatan'],
                                        Icon(Icons.label)),
                                  ),
                                ],
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
