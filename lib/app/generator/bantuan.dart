import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:screenshot/screenshot.dart';
import 'package:jia/common_widgets/sidebar.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:google_fonts/google_fonts.dart';

class Bantuan extends StatefulWidget {
  @override
  _BantuanState createState() => _BantuanState();
}

class _BantuanState extends State<Bantuan> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _generate = '';
  String _alamat = '';
  String _jenisBantuan = '';
  String _tmpGenerate = '';
  String _tmpAlamat = '';
  String _tmpJenisBantuan = '';
  String _tmpTema = 'Tema 1';
  List _listTema = ['Tema 1'];
  DateTime now = DateTime.now();

  Uint8List _imageFile;

  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController controllerNama;
  TextEditingController controllerAlamat;
  TextEditingController controllerBantuan;

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
              'images/bantuan1.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.24 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'TELAH MEMBERIKAN BANTUAN KEPADA',
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 0.018 * MediaQuery.of(context).size.width),
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                top: 0.28 * MediaQuery.of(context).size.width +
                    (_generate.length *
                        0.0013 *
                        MediaQuery.of(context).size.width)),
            alignment: Alignment.center,
            child: Text(
              _generate,
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.brown,
                    fontSize: 0.073 * MediaQuery.of(context).size.width -
                        (_generate.length *
                            0.002 *
                            MediaQuery.of(context).size.width)),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.38 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              _alamat,
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 0.02 * MediaQuery.of(context).size.width),
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.43 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              _jenisBantuan,
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.brown,
                    fontSize: 0.03 * MediaQuery.of(context).size.width),
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.5 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              'Semoga kita semua diberikan kesehatan\ndilimpahkan rezekinya\nserta dimudahkan segala urusannya',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 0.024 * MediaQuery.of(context).size.width),
                fontWeight: FontWeight.w500,
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
                color: Colors.deepOrange,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        title: new Text('Bantuan'),
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
                  controller: controllerAlamat,
                  onChanged: (String str) {
                    _tmpAlamat = str;
                  },
                  decoration: InputDecoration(
                    labelText: 'Masukkan Alamat',
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.65,
                child: TextField(
                  controller: controllerBantuan,
                  onChanged: (String str) {
                    _tmpJenisBantuan = str;
                  },
                  decoration: InputDecoration(
                    labelText: 'Masukkan Jenis Bantuan',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _generate = _tmpGenerate.toUpperCase();
                      _alamat = _stringFormater(_tmpAlamat);
                      _jenisBantuan = _stringFormater(_tmpJenisBantuan);
                    });
                  },
                  icon: Icon(Icons.exit_to_app),
                  label: Text('Generate'),
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
