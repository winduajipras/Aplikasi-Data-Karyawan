import 'package:age/age.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';
import 'package:universal_html/prefer_universal/html.dart' as html;

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

_getMasaKerja(timestamp, timestamp1, timestamp2) {
  if (timestamp == null) return '';
  DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp.seconds * 1000);
  DateTime now = timestamp1 == null
      ? timestamp2
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

DateTime lastDayOfMonth(DateTime month) {
  var beginningNextMonth = (month.month < 12)
      ? new DateTime(month.year, month.month + 1, 1)
      : new DateTime(month.year + 1, 1, 1);
  return beginningNextMonth.subtract(new Duration(days: 1));
}

DateTime firstDayOfMonth(DateTime month) {
  var beginningNextMonth = new DateTime(month.year, month.month, 1);
  return beginningNextMonth;
}

_kehadiran(List dataKehadiran, int index, DateTime _tglMasaKerja) {
  if (dataKehadiran == null) return '';
  DateTime _rangeKehadiran = firstDayOfMonth(_tglMasaKerja);
  DateTime _rangeKehadiran1 = lastDayOfMonth(_tglMasaKerja);
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

  if (index == 0)
    return banyakKehadiran[0].toString();
  else if (index == 1)
    return banyakKehadiran[1].toString();
  else if (index == 2)
    return banyakKehadiran[2].toStringAsFixed(2);
  else if (index == 3)
    return banyakKehadiran[3].toString();
  else if (index == 4)
    return banyakKehadiran[4].toStringAsFixed(2);
  else
    return '';
}

Future<void> generateExcel(List<DocumentSnapshot> document, int index,
    Timestamp time, Timestamp time1, DateTime time2) async {
  //Create a Excel document.
  //Creating a workbook.
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = false;

  // Enable calculation for worksheet.
  sheet.enableSheetCalculations();

  if (index == 0) {
    //Set data in the worksheet.
    sheet.getRangeByName('A1').columnWidth = 5.00;
    sheet.getRangeByName('B1').columnWidth = 25.00;
    sheet.getRangeByName('C1').columnWidth = 18.00;
    sheet.getRangeByName('D1').columnWidth = 18.50;
    sheet.getRangeByName('E1').columnWidth = 16.00;
    sheet.getRangeByName('F1').columnWidth = 65.00;
    sheet.getRangeByName('G1').columnWidth = 17.00;
    sheet.getRangeByName('H1').columnWidth = 22.00;
    sheet.getRangeByName('I1').columnWidth = 12.00;
    sheet.getRangeByName('J1').columnWidth = 9.00;
    sheet.getRangeByName('K1').columnWidth = 13.00;
    sheet.getRangeByName('L1').columnWidth = 18.00;
    sheet.getRangeByName('M1').columnWidth = 16.00;
    sheet.getRangeByName('N1').columnWidth = 16.00;
    sheet.getRangeByName('O1').columnWidth = 18.00;
    sheet.getRangeByName('P1').columnWidth = 17.00;
    sheet.getRangeByName('Q1').columnWidth = 17.00;
    sheet.getRangeByName('R1').columnWidth = 17.00;
    sheet.getRangeByName('S1').columnWidth = 26.00;
    sheet.getRangeByName('T1').columnWidth = 23.00;
    sheet.getRangeByName('U1').columnWidth = 30.00;
    sheet.getRangeByName('V1').columnWidth = 16.00;
    sheet.getRangeByName('W1').columnWidth = 22.00;
    sheet.getRangeByName('X1').columnWidth = 19.00;
    sheet.getRangeByName('Y1').columnWidth = 19.00;
    sheet.getRangeByName('Z1').columnWidth = 20.00;
    sheet.getRangeByName('AA1').columnWidth = 19.00;
    sheet.getRangeByName('AB1').columnWidth = 19.00;
    sheet.getRangeByName('AC1').columnWidth = 6.00;
    sheet.getRangeByName('AD1').columnWidth = 6.00;
    sheet.getRangeByName('AE1').columnWidth = 13.00;
    sheet.getRangeByName('AF1').columnWidth = 18.00;
    sheet.getRangeByName('AG1').columnWidth = 17.00;

    sheet.getRangeByName('A1:AG2').merge();
    sheet.getRangeByName('A1').setText('Data Karyawan Per Tanggal $time2');
    sheet.getRangeByName('A1').cellStyle.hAlign = HAlignType.center;
    sheet.getRangeByName('A1').cellStyle.fontSize = 24;
    sheet.getRangeByName('A1').cellStyle.bold = true;

    final Range range1 = sheet.getRangeByName('A4:AG4');
    range1.cellStyle.fontSize = 11;
    range1.cellStyle.bold = true;
    range1.cellStyle.backColor = '#ffc06e';
    range1.cellStyle.borders.all.lineStyle = LineStyle.thin;
    range1.cellStyle.borders.all.color = '#4a4a4a';

    sheet.getRangeByIndex(4, 1).setText('No.');
    sheet.getRangeByIndex(4, 2).setText('Nama');
    sheet.getRangeByIndex(4, 3).setText('NIK');
    sheet.getRangeByIndex(4, 4).setText('KTP');
    sheet.getRangeByIndex(4, 5).setText('Lokasi');
    sheet.getRangeByIndex(4, 6).setText('Alamat');
    sheet.getRangeByIndex(4, 7).setText('Tempat Lahir');
    sheet.getRangeByIndex(4, 8).setText('Tanggal Lahir');
    sheet.getRangeByIndex(4, 9).setText('Pendidikan');
    sheet.getRangeByIndex(4, 10).setText('G. Darah');
    sheet.getRangeByIndex(4, 11).setText('Kelamin');
    sheet.getRangeByIndex(4, 12).setText('Status');
    sheet.getRangeByIndex(4, 13).setText('Anak Laki-laki');
    sheet.getRangeByIndex(4, 14).setText('Anak Perempuan');
    sheet.getRangeByIndex(4, 15).setText('Ibu Kandung');
    sheet.getRangeByIndex(4, 16).setText('Tanggal Masuk');
    sheet.getRangeByIndex(4, 17).setText('Tanggal Keluar');
    sheet.getRangeByIndex(4, 18).setText('Status Kerja');
    sheet.getRangeByIndex(4, 19).setText('Status Kontrak');
    sheet.getRangeByIndex(4, 20).setText('Masa Kerja');
    sheet.getRangeByIndex(4, 21).setText('Jabatan');
    sheet.getRangeByIndex(4, 22).setText('Klasifikasi Gaji');
    sheet.getRangeByIndex(4, 23).setText('BPJS Ketenagakerjaan');
    sheet.getRangeByIndex(4, 24).setText('Gabung BPJS Ket.');
    sheet.getRangeByIndex(4, 25).setText('Keluar BPJS Ket.');
    sheet.getRangeByIndex(4, 26).setText('BPJS Kesehatan');
    sheet.getRangeByIndex(4, 27).setText('Gabung BPJS Kes.');
    sheet.getRangeByIndex(4, 28).setText('Keluar BPJS Kes.');
    sheet.getRangeByIndex(4, 29).setText('Sakit');
    sheet.getRangeByIndex(4, 30).setText('Cuti');
    sheet.getRangeByIndex(4, 31).setText('Izin Dipotong');
    sheet.getRangeByIndex(4, 32).setText('Izin Tidak Dipotong');
    sheet.getRangeByIndex(4, 33).setText('Total Tidak Masuk');

    int no = 1;
    document.forEach((element) {
      sheet
          .getRangeByName('A${(no + 4)}:AG${(no + 4)}')
          .cellStyle
          .borders
          .all
          .lineStyle = LineStyle.thin;
      sheet
          .getRangeByName('A${(no + 4)}:AG${(no + 4)}')
          .cellStyle
          .borders
          .all
          .color = '#4a4a4a';
      sheet.getRangeByIndex(no + 4, 1).setText(no.toString());
      sheet.getRangeByIndex(no + 4, 2).setText(element.get('nama'));
      sheet.getRangeByIndex(no + 4, 3).setText(element.get('nik'));
      sheet.getRangeByIndex(no + 4, 4).setText(element.get('ktp'));
      sheet.getRangeByIndex(no + 4, 5).setText(element.get('lokasi'));
      sheet.getRangeByIndex(no + 4, 6).setText(element.get('alamat'));
      sheet.getRangeByIndex(no + 4, 7).setText(element.get('tempatLahir'));
      sheet
          .getRangeByIndex(no + 4, 8)
          .setText(_getFormatedDate(element.get('tglLahir')));
      sheet.getRangeByIndex(no + 4, 9).setText(element.get('pendidikan'));
      sheet.getRangeByIndex(no + 4, 10).setText(element.get('golonganDarah'));
      sheet.getRangeByIndex(no + 4, 11).setText(element.get('kelamin'));
      sheet.getRangeByIndex(no + 4, 12).setText(element.get('status'));
      sheet
          .getRangeByIndex(no + 4, 13)
          .setText(element.get('anakLaki').toString());
      sheet
          .getRangeByIndex(no + 4, 14)
          .setText(element.get('anakPerempuan').toString());
      sheet.getRangeByIndex(no + 4, 15).setText(element.get('ibuKandung'));
      sheet
          .getRangeByIndex(no + 4, 16)
          .setText(_getFormatedDate(element.get('tglMasuk')));
      sheet
          .getRangeByIndex(no + 4, 17)
          .setText(_getFormatedDate(element.get('tglKeluar')));
      sheet.getRangeByIndex(no + 4, 18).setText(element.get('aktif'));
      sheet.getRangeByIndex(no + 4, 19).setText(_statusKontrak(
          element.get('pekerjaKontrakLaki'),
          element.get('pekerjaKontrakPerempuan'),
          element.get('pekerjaTetapLaki'),
          element.get('pekerjaTetapPerempuan')));
      sheet.getRangeByIndex(no + 4, 20).setText(_getMasaKerja(
          element.get('tglMasuk'), element.get('tglKeluar'), time2));
      sheet.getRangeByIndex(no + 4, 21).setText(element.get('bagian'));
      sheet.getRangeByIndex(no + 4, 22).setText(element.get('klasifikasiGaji'));
      sheet
          .getRangeByIndex(no + 4, 23)
          .setText(element.get('bpjsKetenagakerjaan')[0]);
      sheet
          .getRangeByIndex(no + 4, 24)
          .setText(_getFormatedDate(element.get('bpjsKetenagakerjaan')[1]));
      sheet
          .getRangeByIndex(no + 4, 25)
          .setText(_getFormatedDate(element.get('bpjsKetenagakerjaan')[2]));
      sheet
          .getRangeByIndex(no + 4, 26)
          .setText(element.get('bpjsKesehatan')[0]);
      sheet
          .getRangeByIndex(no + 4, 27)
          .setText(_getFormatedDate(element.get('bpjsKesehatan')[1]));
      sheet
          .getRangeByIndex(no + 4, 28)
          .setText(_getFormatedDate(element.get('bpjsKesehatan')[2]));
      sheet
          .getRangeByIndex(no + 4, 29)
          .setText(_kehadiran(element.get('vakum'), 0, time2));
      sheet
          .getRangeByIndex(no + 4, 30)
          .setText(_kehadiran(element.get('vakum'), 1, time2));
      sheet
          .getRangeByIndex(no + 4, 31)
          .setText(_kehadiran(element.get('vakum'), 2, time2));
      sheet
          .getRangeByIndex(no + 4, 32)
          .setText(_kehadiran(element.get('vakum'), 3, time2));
      sheet
          .getRangeByIndex(no + 4, 33)
          .setText(_kehadiran(element.get('vakum'), 4, time2));
      no++;
    });
  }

  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();
  //Dispose the document.
  workbook.dispose();

  //Get the storage folder location using path_provider package.
  // final Directory directory = await getExternalStorageDirectory();
  // final String path = directory.path;
  // final File file = File('$path/output.xlsx');
  // await file.writeAsBytes(bytes);

  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.document.createElement('a') as html.AnchorElement
    ..href = url
    ..style.display = 'none'
    ..download = 'output.xlsx';
  html.document.body.children.add(anchor);

  // download
  anchor.click();

  // cleanup
  html.document.body.children.remove(anchor);
  html.Url.revokeObjectUrl(url);
}
