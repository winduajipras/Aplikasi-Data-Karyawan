import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:screenshot/screenshot.dart';
import 'package:jia/common_widgets/sidebar.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker_web/image_picker_web.dart';

class Meninggal extends StatefulWidget {
  final String nama;
  Meninggal({this.nama});
  @override
  _MeninggalState createState() => _MeninggalState();
}

class _MeninggalState extends State<Meninggal> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  String _generate = '';
  String _tmpGenerate = '';
  String _keterangan = '';
  String _tmpKeterangan = '';
  String _lokasi = '';
  String _tmpLokasi = '';
  String _tmpTema = 'Tema 1';
  List _listTema = ['Tema 1', 'Tema 2'];

  Uint8List _imageFile;
  Uint8List _pickedImage;

  ScreenshotController screenshotController = ScreenshotController();
  TextEditingController controllerNama;
  TextEditingController controllerKeterangan;
  TextEditingController controllerLokasi;

  pickImage() async {
    /// You can set the parameter asUint8List to true
    /// to get only the bytes from the image
    Uint8List bytesFromPicker =
        await ImagePickerWeb.getImage(outputType: ImageType.bytes);

    if (bytesFromPicker != null) {
      setState(() {
        _pickedImage = bytesFromPicker;
      });
    }

    /// Default behavior would be getting the Image.memory
    /* Image fromPicker =
        await ImagePickerWeb.getImage(outputType: ImageType.widget);

    if (fromPicker != null) {
      setState(() {
        pickedImage = fromPicker;
      });
    }*/
  }

  _stringFormater(String text) {
    if (text == '') return '';
    String hasil;
    if (text.split(' ').length > 1 && text.length < 5) {
      hasil = ' ';
    } else {
      List<String> split = text.split(' ');
      print(split.length);
      List<String> convert = [];
      split.forEach((element) {
        convert.add(
            '${element[0].toUpperCase()}${element.substring(1).toLowerCase()}');
      });
      hasil = convert.join(' ');
    }
    return hasil;
  }

  _dateFormater(DateTime now) {
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
    return now.day.toString() +
        " " +
        month[now.month - 1] +
        " " +
        now.year.toString();
  }

  _teksIsi(String tema) {
    if (tema == 'Tema 1') {
      return Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              'images/dukaCita1.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding:
                EdgeInsets.only(top: 0.48 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  _generate,
                  style: GoogleFonts.dancingScript(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 0.04 * MediaQuery.of(context).size.width),
                  ),
                ),
                SizedBox(
                  height: 0.014 * MediaQuery.of(context).size.width,
                ),
                Text(
                  _dateFormater(DateTime.now()),
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.017 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.012 * MediaQuery.of(context).size.width,
                ),
                Text(
                  _lokasi,
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.025 * MediaQuery.of(context).size.width),
                  ),
                ),
              ],
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
                  height: 0.013 * MediaQuery.of(context).size.width,
                ),
                Text(
                  'إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ‎',
                  style: GoogleFonts.amiri(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.014 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Turut Berduka Cita',
                  style: GoogleFonts.dancingScript(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.024 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.014 * MediaQuery.of(context).size.width,
                ),
                Text(
                  'Atas Meninggalnya',
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.green,
                        fontSize: 0.017 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.003 * MediaQuery.of(context).size.width,
                ),
                Text(
                  _keterangan,
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.green,
                        fontSize: 0.017 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                top: 0.29 * MediaQuery.of(context).size.width,
                right: 0.6 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              'Semoga diampuni segala dosanya,\ndan diterima semua amal ibadahnya\noleh Allah SWT.',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 0.018 * MediaQuery.of(context).size.width),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                top: 0.29 * MediaQuery.of(context).size.width,
                left: 0.6 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Text(
              'Semoga keluarga yang ditinggalkan\ndiberi kesabaran\ndalam menerima cobaan ini',
              style: GoogleFonts.raleway(
                textStyle: TextStyle(
                    color: Colors.black87,
                    fontSize: 0.018 * MediaQuery.of(context).size.width),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          _pickedImage != null
              ? Padding(
                  padding: EdgeInsets.only(
                      top: 0.2555 * MediaQuery.of(context).size.width),
                  child: Center(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: Container(
                        width: 0.156 * MediaQuery.of(context).size.width,
                        height: 0.156 * MediaQuery.of(context).size.width,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: MemoryImage(_pickedImage),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      );
    } else if (tema == 'Tema 2') {
      return Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Image.asset(
              'images/dukaCita2.jpg',
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                top: 0.23 * MediaQuery.of(context).size.width,
                right: 0.5 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'إِنَّا لِلَّٰهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ‎',
                  style: GoogleFonts.amiri(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.023 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.01 * MediaQuery.of(context).size.width,
                ),
                Text(
                  'Turut Berduka Cita',
                  style: GoogleFonts.dancingScript(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.032 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.014 * MediaQuery.of(context).size.width,
                ),
                Text(
                  'Atas Meninggalnya',
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.green,
                        fontSize: 0.025 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.003 * MediaQuery.of(context).size.width,
                ),
                Text(
                  _keterangan,
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.green,
                        fontSize: 0.025 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  _generate,
                  style: GoogleFonts.dancingScript(
                    textStyle: TextStyle(
                        color: Colors.black,
                        fontSize: 0.07 * MediaQuery.of(context).size.width),
                  ),
                ),
                SizedBox(
                  height: 0.014 * MediaQuery.of(context).size.width,
                ),
                Text(
                  _dateFormater(DateTime.now()),
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.025 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.012 * MediaQuery.of(context).size.width,
                ),
                Text(
                  _lokasi,
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.033 * MediaQuery.of(context).size.width),
                  ),
                ),
              ],
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
                        fontSize: 0.04 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.only(
                top: 0.28 * MediaQuery.of(context).size.width,
                left: 0.4 * MediaQuery.of(context).size.width),
            alignment: Alignment.center,
            child: Column(
              children: [
                Text(
                  'Semoga diampuni segala dosanya,\ndan diterima semua amal ibadahnya\noleh Allah SWT.',
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.025 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  height: 0.03 * MediaQuery.of(context).size.width,
                ),
                Text(
                  'Semoga keluarga yang ditinggalkan\ndiberi kesabaran\ndalam menerima cobaan ini',
                  style: GoogleFonts.raleway(
                    textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 0.025 * MediaQuery.of(context).size.width),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          _pickedImage != null
              ? Padding(
                  padding: EdgeInsets.only(
                      top: 0.03 * MediaQuery.of(context).size.width,
                      right: 0.775 * MediaQuery.of(context).size.width),
                  child: Center(
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(<double>[
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0.2126,
                        0.7152,
                        0.0722,
                        0,
                        0,
                        0,
                        0,
                        0,
                        1,
                        0,
                      ]),
                      child: Container(
                        width: 0.146 * MediaQuery.of(context).size.width,
                        height: 0.146 * MediaQuery.of(context).size.width,
                        decoration: new BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: MemoryImage(_pickedImage),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              : Container(),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
    controllerNama = TextEditingController(text: widget.nama);
    if (widget.nama != null) _generate = _stringFormater(widget.nama);
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
        page: 'berduka',
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
        title: new Text('Berduka'),
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
                  controller: controllerKeterangan,
                  onChanged: (String str) {
                    _tmpKeterangan = str.replaceAll('<br>', '\n');
                  },
                  decoration: InputDecoration(
                    labelText: 'Masukkan Keterangan',
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
                padding: const EdgeInsets.all(14.0),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      pickImage();
                    },
                    icon: Icon(Icons.camera_alt),
                    label: Text('Upload'),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _generate = '';
                        _keterangan = '';
                        _lokasi = '';
                        _pickedImage = null;
                      });
                    },
                    icon: Icon(Icons.clear_rounded),
                    label: Text('Clear'),
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _generate = _stringFormater(_tmpGenerate);
                        _keterangan = _stringFormater(_tmpKeterangan);
                        _lokasi = _stringFormater(_tmpLokasi);
                      });
                    },
                    icon: Icon(Icons.exit_to_app),
                    label: Text('Generate'),
                  ),
                ]),
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
