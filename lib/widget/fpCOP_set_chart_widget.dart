import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

// import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:community_material_icon/community_material_icon.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

// import 'package:block001/model/constant.dart';
import 'package:block001/model/util.dart';
import 'package:block001/model/udp_com.dart';
import 'package:block001/model/fp_samp_info.dart';

// FP COPグラフ表示
class FpCOPSetChartWidget extends ConsumerStatefulWidget {
  FpCOPSetChartWidget({
    Key? key,
    required this.sampList1,
    required this.sampList2,
    required this.startAt,
  }) : super(key: key);

  List<FpSampInfo> sampList1;
  List<FpSampInfo> sampList2;
  DateTime startAt;

  @override
  _FpCOPSetChartWidget createState() => _FpCOPSetChartWidget();
}

class _FpCOPSetChartWidget extends ConsumerState<FpCOPSetChartWidget> {
  late List<FpSampInfo> _sampList1;
  late List<FpSampInfo> _sampList2;
  late DateTime _startAt;

  // double _fontSize = 7;
  double _fontSize = 14;

  @override
  void initState() {
    _sampList1 = widget.sampList1;
    _sampList2 = widget.sampList2;
    _startAt = widget.startAt;

    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _bodyWidget(),
    );
  }

  Widget _bodyWidget() {
    List<LineSeries<_ChartData, double>> chartData = _getDefaultLineSeries();
    // if (chartData.length == 0) {
    if (chartData.length == 0) {
      print('グラフデータ：データなし:' + chartData.length.toString());
      return Text(
        '読み込み中',
        style: TextStyle(
          fontSize: _fontSize,
        ),
      );
    }

    double chartIntterval = 1;
    // if (chartData[0].dataSource.length < 60 * 10) {
    //   chartIntterval = 1;
    // } else if (chartData[0].dataSource.length < 60 * 60) {
    //   chartIntterval = 5;
    // } else {
    //   chartIntterval = 10;
    // }
    // if (_sampList.last.secCnt < 60 * 10) {
    //   chartIntterval = 1;
    // } else if (_sampList.last.secCnt < 60 * 60) {
    //   chartIntterval = 5;
    // } else {
    //   chartIntterval = 10;
    // }

    return SfCartesianChart(
      legend: Legend(
        isVisible: true,
      ),
      // X軸（時間）
      primaryXAxis: NumericAxis(
        // intervalType: DateTimeIntervalType.minutes,
        // intervalType: DateTimeIntervalType.seconds,
        // interval: 5,
        // interval: chartIntterval,
        // dateFormat: DateFormat.Hm(),
        // dateFormat: DateFormat.ms(),
        labelFormat: '{value}',
        minimum: -0.4,
        maximum: 0.4,
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          fontSize: _fontSize,
          color: Colors.black,
        ),
      ),
      // Y軸（歩数）
      primaryYAxis: NumericAxis(
        // opposedPosition: true,
        // axisLine: AxisLine(width: 0),
        // majorTickLines: MajorTickLines(color: Colors.transparent),
        labelFormat: '{value}',
        minimum: -0.2,
        maximum: 0.2,
        // minimum: minLine.toDouble(),
        // maximum: maxLine.toDouble(),
        // interval: 20,
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: TextStyle(
          // color: Colors.red,
          fontSize: _fontSize,
        ),
      ),
      // axes: <ChartAxis>[
      //   NumericAxis(
      //     numberFormat: NumberFormat.compact(),
      //     majorGridLines: const MajorGridLines(width: 0),
      //     opposedPosition: true,
      //     name: 'yAxis1',
      //     // interval: 1000,
      //     // minimum: 0,
      //     // maximum: 7000,
      //   )
      // ],
      series: chartData,
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  List<LineSeries<_ChartData, double>> _getDefaultLineSeries() {
    // List<_ChartData> chartData = [];
    // print("グラフ表示：" + chartData.length.toString());

    List<_ChartData> chartData = [];

    DateTime now_dt = DateTime.now();

    int num = _sampList1.length > _sampList2.length ? _sampList2.length : _sampList1.length;
    for (int i = 0; i < num; i++) {
      // DateTime x_dt = _startAt.add(Duration(seconds: _accSampList[i].secCnt));
      // DateTime x_dt = _startAt.add(Duration(milliseconds: i));
      // DateTime x_dt = _startAt.add(Duration(milliseconds: _sampList[i].rxCnt));
      //
      // if (x_dt.compareTo(now_dt.subtract(Duration(seconds: 10 * 1))) < 0) {
      //   continue;
      // }

      Color color = Colors.red;

      double COPx1 = _sampList1[i].Fz >= 15
          ? (_sampList1[i].My - _sampList1[i].Fx * 0.011) / _sampList1[i].Fz
          : 0;
      double COPy1 = _sampList1[i].Fz >= 15
          ? -1 * (_sampList1[i].Mx + _sampList1[i].Fy * 0.011) / _sampList1[i].Fz
          : 0;

      double COPx2 = _sampList2[i].Fz >= 15
          ? (_sampList2[i].My - _sampList2[i].Fx * 0.011) / _sampList2[i].Fz
          : 0;
      double COPy2 = _sampList2[i].Fz >= 15
          ? -1 * (_sampList2[i].Mx + _sampList2[i].Fy * 0.011) / _sampList2[i].Fz
          : 0;

      double COPx = ((COPx1 - 0.2) * _sampList1[i].Fz
          + (COPx2 + 0.2) * _sampList2[i].Fz) / (_sampList1[i].Fz + _sampList2[i].Fz);
      double COPy = ((COPy1) * _sampList1[i].Fz
          + (COPy2) * _sampList2[i].Fz) / (_sampList1[i].Fz + _sampList2[i].Fz);

      _ChartData cd = _ChartData(
        COPx,
        COPy,
        color,
      );

      chartData.add(cd);
    }

    // print("グラフ表示：" + chartData.length.toString());
    // if (chartData.length == 0) {
    if (chartData.length < 3) {
      List<LineSeries<_ChartData, double>> none = [];
      return none;
    }

    // return <LineSeries<_ChartData, num>>[
    return <LineSeries<_ChartData, double>>[
      LineSeries<_ChartData, double>(
        animationDuration: 0,
        dataSource: chartData,
        width: 2,
        name: 'COP',
        enableTooltip: false,
        color: Colors.red,
        // pointColorMapper: (_ChartData sales, _) => sales.color,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y,
//          markerSettings: MarkerSettings(isVisible: true)
      ),
      // LineSeries<_ChartData, DateTime>(
      //   animationDuration: 0,
      //   dataSource: chartData,
      //   // yAxisName: 'yAxis1',
      //   width: 2,
      //   name: 'Fy',
      //   color: Colors.blue,
      //   xValueMapper: (_ChartData sales, _) => sales.x,
      //   yValueMapper: (_ChartData sales, _) => sales.y2,
      //   // markerSettings: MarkerSettings(isVisible: true)
      // ),
      // LineSeries<_ChartData, DateTime>(
      //   animationDuration: 0,
      //   dataSource: chartData,
      //   // yAxisName: 'yAxis1',
      //   width: 2,
      //   name: 'Fz',
      //   color: Colors.green,
      //   xValueMapper: (_ChartData sales, _) => sales.x,
      //   yValueMapper: (_ChartData sales, _) => sales.y3,
      //   // markerSettings: MarkerSettings(isVisible: true)
      // ),
    ];
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.color);
  final double x;
  // final DateTime x;
  final double y;
  // final double y2;
  // final double y3;
  final Color color;
// final double y2;
}
