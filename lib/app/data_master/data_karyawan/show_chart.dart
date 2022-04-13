import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ShowChart extends StatefulWidget {
  final String lokasi;
  final List<DocumentSnapshot> query;
  final DateTime rangeKehadiran;
  final DateTime rangeKehadiran1;
  final bool monthly;
  ShowChart(
      {this.lokasi,
      this.query,
      this.rangeKehadiran,
      this.rangeKehadiran1,
      this.monthly});
  @override
  _ShowChartState createState() => _ShowChartState();
}

class _ShowChartState extends State<ShowChart> {
  _getMonth(i) {
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
    return month[i - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: new Text('Chart Lokasi [ ${widget.lokasi} ]'),
      ),
      body: SfCartesianChart(
        plotAreaBorderWidth: 0,
        title: ChartTitle(
            text: widget.monthly
                ? 'Grafik Kehadiran Karyawan Per Bulan ${_getMonth(widget.rangeKehadiran.month)}'
                : 'Grafik Kehadiran Karyawan Per Tahun ${widget.rangeKehadiran.year}'),
        legend: Legend(isVisible: true),
        primaryXAxis: CategoryAxis(
          title: AxisTitle(text: 'Tanggal'),
          majorGridLines: MajorGridLines(width: 0),
          labelPlacement: LabelPlacement.onTicks,
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(text: 'Tidak Masuk'),
          minimum: 0,
          maximum: widget.monthly ? 1 : 10,
          axisLine: AxisLine(width: 0),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          labelFormat: '{value} hari',
          majorTickLines: MajorTickLines(size: 0),
        ),
        series: _getDefaultSplineSeries(),
        tooltipBehavior: TooltipBehavior(
          enable: true,
        ),
      ),
    );
  }

  /// Returns the list of chart series which need to render on the spline chart.
  List<SplineSeries<ChartSampleData, String>> _getDefaultSplineSeries() {
    List<ChartSampleData> chartData = <ChartSampleData>[];
    if (widget.query != null) {
      for (var i = 1;
          i <
              (widget.monthly
                      ? widget.rangeKehadiran1.day
                      : widget.rangeKehadiran1.month) +
                  1;
          i++) {
        List _dataKehadiran = List.filled(widget.query.length, 0);
        for (var j = 0; j < widget.query.length; j++) {
          if (widget.query[j].get('vakum') != null) {
            for (var k = 0; k < widget.query[j].get('vakum').length; k++) {
              if (widget.query[j].get('vakum')[k]['tanggalVakum'].seconds >=
                      Timestamp.fromDate(
                        widget.rangeKehadiran.subtract(
                          Duration(
                              hours: widget.rangeKehadiran.hour,
                              minutes: widget.rangeKehadiran.minute,
                              seconds: widget.rangeKehadiran.second),
                        ),
                      ).seconds &&
                  widget.query[j].get('vakum')[k]['tanggalVakum'].seconds <=
                      Timestamp.fromDate(
                        widget.rangeKehadiran1.add(
                          Duration(
                              hours: 23 - widget.rangeKehadiran1.hour,
                              minutes: 59 - widget.rangeKehadiran1.minute,
                              seconds: 59 - widget.rangeKehadiran1.second),
                        ),
                      ).seconds) {
                if (widget.monthly &&
                    DateTime.fromMillisecondsSinceEpoch(widget.query[j]
                                    .get('vakum')[k]['tanggalVakum']
                                    .seconds *
                                1000)
                            .day ==
                        i) {
                  if (widget.query[j].get('vakum')[k]['kategori'] ==
                      'Izin Dipotong') {
                    if (double.tryParse(widget.query[j]
                            .get('vakum')[k]['keterangan']
                            .split(' ')[0]) !=
                        null) {
                      _dataKehadiran[j] = double.parse(widget.query[j]
                              .get('vakum')[k]['keterangan']
                              .split(' ')[0]) /
                          7;
                    }
                  } else {
                    _dataKehadiran[j] = 1;
                  }
                } else if (!widget.monthly &&
                    DateTime.fromMillisecondsSinceEpoch(widget.query[j]
                                    .get('vakum')[k]['tanggalVakum']
                                    .seconds *
                                1000)
                            .month ==
                        i) {
                  if (widget.query[j].get('vakum')[k]['kategori'] ==
                      'Izin Dipotong') {
                    if (double.tryParse(widget.query[j]
                            .get('vakum')[k]['keterangan']
                            .split(' ')[0]) !=
                        null) {
                      _dataKehadiran[j] += double.parse(widget.query[j]
                              .get('vakum')[k]['keterangan']
                              .split(' ')[0]) /
                          7;
                    }
                  } else {
                    _dataKehadiran[j] += 1;
                  }
                }
              }
            }
          }
        }
        chartData.add(
          ChartSampleData(
            x: widget.monthly ? i.toString() : _getMonth(i),
            listY: _dataKehadiran,
          ),
        );
      }
      return List<SplineSeries<ChartSampleData, String>>.generate(
        widget.query.length,
        (index) => SplineSeries<ChartSampleData, String>(
          splineType: SplineType.monotonic,
          dataSource: chartData,
          name: widget.query[index].get('nama'),
          markerSettings: MarkerSettings(isVisible: true),
          xValueMapper: (ChartSampleData sales, _) => sales.x,
          yValueMapper: (ChartSampleData sales, _) => sales.listY[index],
        ),
      );
    } else {
      return null;
    }
  }
}

///Chart sample data
class ChartSampleData {
  /// Holds the datapoint values like x, y, etc.,
  ChartSampleData({
    this.x,
    this.listY,
  });

  /// Holds x value of the datapoint
  final dynamic x;

  /// hold list Y
  final List listY;
}
