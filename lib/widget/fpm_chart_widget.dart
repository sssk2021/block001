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

// FP モーメントグラフ表示
class FpMChartWidget extends ConsumerStatefulWidget {
  FpMChartWidget({
    Key? key,
    required this.sampList,
    required this.startAt,
  }) : super(key: key);

  List<FpSampInfo> sampList;
  DateTime startAt;

  @override
  _FpMChartWidget createState() => _FpMChartWidget();
}

class _FpMChartWidget extends ConsumerState<FpMChartWidget> {
  late List<FpSampInfo> _sampList;
  late DateTime _startAt;

  // double _fontSize = 7;
  double _fontSize = 14;

  @override
  void initState() {
    _sampList = widget.sampList;
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
    List<LineSeries<_ChartData, DateTime>> chartData = _getDefaultLineSeries();
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
      primaryXAxis: DateTimeAxis(
        // intervalType: DateTimeIntervalType.minutes,
        intervalType: DateTimeIntervalType.seconds,
        interval: 5,
        // interval: chartIntterval,
        // dateFormat: DateFormat.Hm(),
        dateFormat: DateFormat.ms(),
        majorGridLines: MajorGridLines(width: 1),
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
        minimum: -100,
        maximum: 100,
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

  List<LineSeries<_ChartData, DateTime>> _getDefaultLineSeries() {
    // List<_ChartData> chartData = [];
    // print("グラフ表示：" + chartData.length.toString());

    List<_ChartData> chartData = [];

    DateTime now_dt = DateTime.now();

    for (int i = 0; i < _sampList.length; i++) {
      // DateTime x_dt = _startAt.add(Duration(seconds: _accSampList[i].secCnt));
      // DateTime x_dt = _startAt.add(Duration(milliseconds: i));
      DateTime x_dt = _startAt.add(Duration(milliseconds: _sampList[i].rxCnt));

      if (x_dt.compareTo(now_dt.subtract(Duration(seconds: 10 * 1))) < 0) {
        continue;
      }

      // DateTime x_dt = _sampList[i].rxDt;

      // // 3分間表示の場合
      // if (_shortFlag != false) {
      //   // if (DateTime.now().difference(x_dt) >= Duration(seconds: 180)) {
      //   int difSec = now_dt.difference(x_dt).inSeconds;
      //   if (difSec >= 180) {
      //     // print('i:' + i.toString() + ' difSec:' + difSec.toString() + ' secCnt:' + _hrSampList[i].secCnt.toString() + ' x_dt:' + x_dt.toString() + ' now_dt:' + now_dt.toString());
      //     continue;
      //   }
      // }

      Color color = Colors.red;
      // if (_sectStartTime != null && _sectEndTime! != null) {
      //   if (x_dt == _sectStartTime ||
      //       x_dt == _sectEndTime ||
      //       (x_dt.isAfter(_sectStartTime!) && x_dt.isBefore(_sectEndTime!))) {
      //     color = Colors.deepPurpleAccent;
      //   }
      // }

      _ChartData cd = _ChartData(
        x_dt,
        _sampList[i].Mx.toDouble(),
        _sampList[i].My.toDouble(),
        _sampList[i].Mz.toDouble(),
        color,
      );

      chartData.add(cd);
    }

    // print("グラフ表示：" + chartData.length.toString());
    // if (chartData.length == 0) {
    if (chartData.length < 3) {
      List<LineSeries<_ChartData, DateTime>> none = [];
      return none;
    }

    // return <LineSeries<_ChartData, num>>[
    return <LineSeries<_ChartData, DateTime>>[
      LineSeries<_ChartData, DateTime>(
        animationDuration: 0,
        dataSource: chartData,
        width: 2,
        name: 'Mx',
        enableTooltip: false,
        color: Colors.red,
        // pointColorMapper: (_ChartData sales, _) => sales.color,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y,
//          markerSettings: MarkerSettings(isVisible: true)
      ),
      LineSeries<_ChartData, DateTime>(
        animationDuration: 0,
        dataSource: chartData,
        // yAxisName: 'yAxis1',
        width: 2,
        name: 'My',
        color: Colors.blue,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y2,
        // markerSettings: MarkerSettings(isVisible: true)
      ),
      LineSeries<_ChartData, DateTime>(
        animationDuration: 0,
        dataSource: chartData,
        // yAxisName: 'yAxis1',
        width: 2,
        name: 'Mz',
        color: Colors.green,
        xValueMapper: (_ChartData sales, _) => sales.x,
        yValueMapper: (_ChartData sales, _) => sales.y3,
        // markerSettings: MarkerSettings(isVisible: true)
      ),
    ];
  }
}

class _ChartData {
  _ChartData(this.x, this.y, this.y2, this.y3, this.color);
  // final double x;
  final DateTime x;
  final double y;
  final double y2;
  final double y3;
  final Color color;
// final double y2;
}
