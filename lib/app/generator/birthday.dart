import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:screenshot/screenshot.dart';
import 'package:jia/common_widgets/sidebar.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:google_fonts/google_fonts.dart';

class UlangTahun extends StatefulWidget {
  final String nama;
  final Timestamp tglLahir;
  final String jabatan;
  final String lokasi;
  UlangTahun({this.nama, this.tglLahir, this.jabatan, this.lokasi});
  @override
  _UlangTahunState createState() => _UlangTahunState();
}

class _UlangTahunState extends State<UlangTahun> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _generate = '';
  String _jabatan = '';
  String _lokasi = '';
  String _tmpGenerate = '';
  String _tmpJabatan = '';
  String _tmpLokasi = '';
  String _tmpTema = 'Tema 1';
  List _listTema = ['Tema 1', 'Tema 2'];
  DateTime now = DateTime.now();

  Uint8List _imageFile;

  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController controllerNama;
  TextEditingController controllerJabatan;
  TextEditingController controllerLokasi;

  _selectDates(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: now, // Refer step 1
      firstDate: DateTime(1940),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != now) {
      setState(() {
        now = picked;
      });
    }
  }

  _stringFormater(String text) {
    if (text == '') return '';
    List<String> split = text.split(' ');
    List<String> convert = [];
    split.forEach((element) {
      convert.add(
          '${element[0].toUpperCase()}${element.substring(1).toLowerCase()}');
    });
    String hasil = convert.join(' ');
    return hasil;
  }

  _teksIsi(String tema) {
    if (tema == 'Tema 1') {
      return Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              'images/ulangTahun2.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.39 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              _generate,
              style: GoogleFonts.greatVibes(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 0.04 * MediaQuery.of(context).size.width),
              ),
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.015 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Jatinom Indah Group\nDiv. Personalia',
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.03 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.03 * MediaQuery.of(context).size.width,
                ),
                Text(
                  'Mengucapkan',
                  style: GoogleFonts.greatVibes(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.024 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.26 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              'SELAMAT',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 0.028 * MediaQuery.of(context).size.width),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.28 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              'Ulang Tahun',
              style: GoogleFonts.greatVibes(
                textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 0.093 * MediaQuery.of(context).size.width),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.43 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              now.day.toString() +
                  " - " +
                  now.month.toString() +
                  ' - ' +
                  now.year.toString(),
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 0.018 * MediaQuery.of(context).size.width),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.45 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              _jabatan != '' && _lokasi != ''
                  ? _jabatan + ' - ' + _lokasi
                  : _jabatan + '' + _lokasi,
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 0.018 * MediaQuery.of(context).size.width),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.49 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              'Semoga senantiasa diberikan\nkesehatan, kelancaran rezeki, dan\ntambah semangat bekerja untuk \nkeluarga tercinta',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 0.024 * MediaQuery.of(context).size.width),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      );
    } else if (tema == 'Tema 2') {
      return Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              'images/ulangTahun1.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.39 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              _generate,
              style: GoogleFonts.greatVibes(
                textStyle: TextStyle(
                    color: Colors.white,
                    fontSize: 0.04 * MediaQuery.of(context).size.width),
              ),
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.015 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Jatinom Indah Group\nDiv. Personalia',
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 0.03 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.03 * MediaQuery.of(context).size.width,
                ),
                Text(
                  'Mengucapkan',
                  style: GoogleFonts.greatVibes(
                    textStyle: TextStyle(
                        color: Colors.white70,
                        fontSize: 0.024 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.43 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              now.day.toString() +
                  " - " +
                  now.month.toString() +
                  ' - ' +
                  now.year.toString(),
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 0.018 * MediaQuery.of(context).size.width),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.49 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              'Semoga senantiasa diberikan\nkesehatan, kelancaran rezeki, dan\ntambah semangat bekerja untuk \nkeluarga tercinta',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 0.024 * MediaQuery.of(context).size.width),
              ),
              textAlign: TextAlign.center,
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
    controllerJabatan = TextEditingController(text: widget.jabatan);
    controllerLokasi = TextEditingController(text: widget.lokasi);
    if (widget.nama != null) _generate = _stringFormater(widget.nama);
    if (widget.jabatan != null) _jabatan = _stringFormater(widget.jabatan);
    if (widget.lokasi != null) _lokasi = _stringFormater(widget.lokasi);
    if (widget.tglLahir != null)
      now = DateTime.fromMillisecondsSinceEpoch(widget.tglLahir.seconds * 1000);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _generate.length == 0
          ? FloatingActionButton(
              backgroundColor: Colors.grey,
              child: const Icon(Icons.download_sharp),
              onPressed: null)
          : FloatingActionButton(
              backgroundColor: Colors.deepPurple,
              child: const Icon(Icons.download_sharp),
              onPressed: () {
                _imageFile = null;
                screenshotController
                    .capture(delay: Duration(milliseconds: 10))
                    .then((Uint8List image) async {
                  _imageFile = image;
                  final blob = html.Blob([_imageFile]);
                  final url = html.Url.createObjectUrlFromBlob(blob);
                  final anchor =
                      html.document.createElement('a') as html.AnchorElement
                        ..href = url
                        ..style.display = 'none'
                        ..download = DateTime.now().toString() + '.jpg';
                  html.document.body.children.add(anchor);

                  // download
                  anchor.click();

                  // cleanup
                  html.document.body.children.remove(anchor);
                  html.Url.revokeObjectUrl(url);
                });
              },
            ),
      drawer: SideBar(
        page: 'ulang tahun',
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
        title: new Text('Ulang Tahun'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              DropdownButton(
                value: _tmpTema,
                items: _listTema.map((e) {
                  return DropdownMenuItem(child: Text(e), value: e);
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _tmpTema = value;
                  });
                },
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                child: TextField(
                  controller: controllerNama,
                  onChanged: (String str) {
                    _tmpGenerate = str;
                  },
                  decoration: InputDecoration(
                    labelText: 'Masukkan Nama',
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                child: TextField(
                  controller: controllerJabatan,
                  onChanged: (String str) {
                    _tmpJabatan = str;
                  },
                  decoration: InputDecoration(
                    labelText: 'Masukkan Jabatan',
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                child: TextField(
                  controller: controllerLokasi,
                  onChanged: (String str) {
                    _tmpLokasi = str;
                  },
                  decoration: InputDecoration(
                    labelText: 'Masukkan Lokasi',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _selectDates(context);
                      },
                      icon: Icon(Icons.calendar_today),
                      label: Text('Tgl Lahir'),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _generate = _stringFormater(_tmpGenerate);
                          _jabatan = _stringFormater(_tmpJabatan);
                          _lokasi = _stringFormater(_tmpLokasi);
                        });
                      },
                      icon: Icon(Icons.exit_to_app),
                      label: Text('Generate'),
                    ),
                  ],
                ),
              ),
              _generate.length == 0
                  ? Container(
                      padding: EdgeInsets.only(top: 30.0),
                      child: SpinKitChasingDots(
                        duration: const Duration(milliseconds: 1000),
                        color: Colors.deepPurple,
                        size: 70.0,
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(top: 30.0),
                      child: Screenshot(
                        controller: screenshotController,
                        child: _teksIsi(_tmpTema),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
