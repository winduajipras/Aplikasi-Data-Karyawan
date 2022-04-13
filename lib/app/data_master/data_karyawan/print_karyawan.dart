import 'dart:typed_data';

import 'package:age/age.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// ignore: must_be_immutable
class PrintKaryawan extends StatelessWidget {
  PrintKaryawan({
    this.document,
    this.tglMasaKerja,
  });
  final Map document;
  final DateTime tglMasaKerja;
  final String title = "Preview";
  DateTime now = DateTime.now();
  final baseColor = PdfColors.deepOrange;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: PdfPreview(
        pageFormats: {
          'A4': PdfPageFormat.a4,
          'F4': PdfPageFormat(21.59 * PdfPageFormat.cm, 33 * PdfPageFormat.cm,
              marginAll: 1.25 * PdfPageFormat.cm),
          'Letter': PdfPageFormat.letter,
        },
        canChangePageFormat: false,
        build: (format) => _generatePdf(format, title),
      ),
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document();
    format = PdfPageFormat(21.59 * PdfPageFormat.cm, 33 * PdfPageFormat.cm,
        marginAll: 1.25 * PdfPageFormat.cm);

    AssetImage imageProvider = AssetImage(
        'images/' + document['perusahaan'].replaceAll(' ', '') + '.JPG');

    NetworkImage imageAvatar = NetworkImage(document['avatar'] != null
        ? document['avatar']
        : 'https://firebasestorage.googleapis.com/v0/b/pt-jatinom-indah-agri.appspot.com/o/users%2Fdefault.jpg?alt=media&token=cedb0e32-20c2-43d0-92e5-f06680af4c5a');

    final image = await flutterImageProvider(imageProvider);
    final pp = await flutterImageProvider(imageAvatar);

    Map _listKategoriShowPersonal = {
      'nama': 'Nama Lengkap',
      'nik': 'NIK',
      'ktp': 'KTP',
      'lokasi': 'Lokasi',
      'alamat': 'Alamat',
      'tempatLahir': 'Tempat Lahir',
      'tglLahir': 'Tanggal Lahir',
      'pendidikan': 'Pendidikan Terakhir',
      'sekolah': 'Nama Sekolah',
      'jurusan': 'Jurusan',
      'golonganDarah': 'Golongan Darah',
      'kelamin': 'Jenis Kelamin',
    };

    Map _listKategoriShowFamily = {
      'status': 'Status Perkawinan',
      'anakLaki': 'Jumlah Anak Laki-Laki',
      'anakPerempuan': 'Jumlah Anak Perempuan',
      'ibuKandung': 'Nama Ibu Kandung',
    };

    Map _listKategoriShowWork = {
      'tglMasuk': 'Tanggal Masuk',
      'tglKeluar': 'Tanggal Keluar',
      'aktif': 'Status Kerja',
      'statusKontrak': 'Status Pekerja',
      'masaKerja': 'Masa Kerja',
      'tglPensiun': 'Tanggal Pensiun',
      'bagian': 'Jabatan',
      'klasifikasiGaji': 'Klasifikasi Gaji',
      'perusahaan': 'Perusahaan',
    };

    Map _listKategoriShowBPJS = {
      'bpjsKetenagakerjaan': 'BPJS Ketenagakerjaan',
      'bpjsKesehatan': 'BPJS Kesehatan',
    };

    final data1 = [
      ['', '']
    ];

    final data2 = [
      ['', '']
    ];

    final data3 = [
      ['', '']
    ];

    final data4 = [
      ['', '']
    ];

    final data5 = [
      ['']
    ];

    final data6 = [
      ['']
    ];

    final data7 = [
      ['']
    ];

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

    _getPensiun(timestamp) {
      if (timestamp == null) return '';
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
      DateTime pensiun = Age.add(date: date, duration: AgeDuration(years: 57));
      return _getFormatedDate(Timestamp.fromDate(pensiun));
    }

    _getMasaKerja(timestamp, timestamp1) {
      if (timestamp == null) return '';
      DateTime date =
          DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
      DateTime now = timestamp1 == null
          ? tglMasaKerja
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

    _listKategoriShowPersonal.forEach((key, value) {
      if (key == 'tglLahir') {
        data1.add([value, _getFormatedDate(document[key])]);
      } else {
        data1.add([value, document[key]]);
      }
    });
    data1.removeAt(0);

    _listKategoriShowFamily.forEach((key, value) {
      if (key == 'anakLaki' || key == 'anakPerempuan') {
        data2.add([value, document[key].toString()]);
      } else {
        data2.add([value, document[key]]);
      }
    });
    data2.removeAt(0);

    _listKategoriShowWork.forEach((key, value) {
      if (key == 'tglMasuk' || key == 'tglKeluar') {
        data3.add([value, _getFormatedDate(document[key])]);
      } else if (key == 'statusKontrak') {
        data3.add([
          value,
          _statusKontrak(
              document['pekerjaKontrakLaki'],
              document['pekerjaKontrakPerempuan'],
              document['pekerjaTetapLaki'],
              document['pekerjaTetapPerempuan'],
              document['pekerjaHarianTetapLaki'],
              document['pekerjaHarianTetapPerempuan'],
              document['pekerjaHarianTidakTetapLaki'],
              document['pekerjaHarianTidakTetapPerempuan'])
        ]);
      } else if (key == 'masaKerja') {
        data3.add([
          value,
          _getMasaKerja(document['tglMasuk'], document['tglKeluar'])
        ]);
      } else if (key == 'tglPensiun') {
        data3.add([value, _getPensiun(document['tglLahir'])]);
      } else {
        data3.add([value, document[key]]);
      }
    });
    data3.removeAt(0);

    _listKategoriShowBPJS.forEach((key, value) {
      data4.add([value, document[key][0]]);
      data4.add(['Tanggal Gabung', _getFormatedDate(document[key][1])]);
    });
    data4.removeAt(0);

    document['riwayatPendidikan'].forEach((element) {
      data5.add([element]);
    });
    data5.removeAt(0);

    document['pengalamanKerja'].forEach((element) {
      data6.add([element]);
    });
    data6.removeAt(0);

    document['riwayatJabatan'].forEach((element) {
      data7.add([element]);
    });
    data7.removeAt(0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: format,
        build: (pw.Context context) {
          return <pw.Widget>[
            //kop
            pw.Container(
              alignment: pw.Alignment.topCenter,
              child: pw.Image(image),
            ),
            pw.Stack(
              alignment: pw.Alignment.topRight,
              children: [
                //personal
                pw.Table.fromTextArray(
                  cellAlignment: pw.Alignment.centerLeft,
                  columnWidths: {
                    0: pw.FixedColumnWidth(10.0),
                    1: pw.FixedColumnWidth(20.0),
                  },
                  cellStyle: pw.TextStyle(fontSize: 10.0),
                  border: null,
                  headers: ['Pribadi'],
                  data: data1,
                  headerStyle: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                  ),
                  headerDecoration: pw.BoxDecoration(
                    color: baseColor,
                  ),
                  rowDecoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: baseColor,
                        width: .5,
                      ),
                    ),
                  ),
                ),
                pw.Container(
                  width: 80.0,
                  height: 100.0,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.white, width: 10),
                    image: pw.DecorationImage(
                      fit: pw.BoxFit.fitHeight,
                      image: pp,
                    ),
                  ),
                ),
              ],
            ),
            //family
            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: pw.FixedColumnWidth(10.0),
                1: pw.FixedColumnWidth(20.0),
              },
              cellStyle: pw.TextStyle(fontSize: 10.0),
              border: null,
              headers: ['Keluarga'],
              data: data2,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(
                color: baseColor,
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: baseColor,
                    width: .5,
                  ),
                ),
              ),
            ),
            //work
            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: pw.FixedColumnWidth(10.0),
                1: pw.FixedColumnWidth(20.0),
              },
              cellStyle: pw.TextStyle(fontSize: 10.0),
              border: null,
              headers: ['Pekerjaan'],
              data: data3,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(
                color: baseColor,
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: baseColor,
                    width: .5,
                  ),
                ),
              ),
            ),
            //BPJS
            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: pw.FixedColumnWidth(10.0),
                1: pw.FixedColumnWidth(20.0),
              },
              cellStyle: pw.TextStyle(fontSize: 10.0),
              border: null,
              headers: ['BPJS'],
              data: data4,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(
                color: baseColor,
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: baseColor,
                    width: .5,
                  ),
                ),
              ),
            ),
          ];
          // return pw.Center(
          //   child: pw.Text(title),
          // );
        },
      ),
    );

    pdf.addPage(pw.MultiPage(
        pageFormat: format,
        build: (pw.Context context) {
          return <pw.Widget>[
            // Riwayat Pendidikan
            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: pw.FixedColumnWidth(10.0),
                1: pw.FixedColumnWidth(20.0),
              },
              cellStyle: pw.TextStyle(fontSize: 10.0),
              border: null,
              headers: ['Riwayat Pendidikan'],
              data: data5,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(
                color: baseColor,
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: baseColor,
                    width: .5,
                  ),
                ),
              ),
            ),

            // Pengalaman Kerja
            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: pw.FixedColumnWidth(10.0),
                1: pw.FixedColumnWidth(20.0),
              },
              cellStyle: pw.TextStyle(fontSize: 10.0),
              border: null,
              headers: ['Pengalaman Kerja'],
              data: data6,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(
                color: baseColor,
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: baseColor,
                    width: .5,
                  ),
                ),
              ),
            ),

            // Riwayat Jabatan
            pw.Table.fromTextArray(
              cellAlignment: pw.Alignment.centerLeft,
              columnWidths: {
                0: pw.FixedColumnWidth(10.0),
                1: pw.FixedColumnWidth(20.0),
              },
              cellStyle: pw.TextStyle(fontSize: 10.0),
              border: null,
              headers: ['Riwayat Jabatan'],
              data: data7,
              headerStyle: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
              ),
              headerDecoration: pw.BoxDecoration(
                color: baseColor,
              ),
              rowDecoration: pw.BoxDecoration(
                border: pw.Border(
                  bottom: pw.BorderSide(
                    color: baseColor,
                    width: .5,
                  ),
                ),
              ),
            ),
          ];
        }));
    return pdf.save();
  }
}
