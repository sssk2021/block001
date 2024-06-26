import 'dart:async';
import 'dart:math';

import 'package:block001/widget/fpCOP_chart_widget.dart';
import 'package:block001/widget/fpCOP_set_chart_widget.dart';
import 'package:block001/widget/fpm_chart_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:block001/model/util.dart';
// import 'package:block001/model/udp_com.dart';
import 'package:block001/model/tcp_com.dart';
import 'package:block001/model/fp_samp_info.dart';
import 'package:block001/widget/fpf_chart_widget.dart';

// 通信確認用画面
class ComCheckView extends ConsumerStatefulWidget {
  ComCheckView({Key? key}) : super(key: key);

  @override
  _ComCheckView createState() => _ComCheckView();

  static const String pageName = '/com-check-view';

  // 画面遷移
  static Future<Object?> pushPage(BuildContext context) async {
    var retVal = await Navigator.of(context).pushNamed(pageName);
    return Future.value(retVal);
  }
}

class _ComCheckView extends ConsumerState<ComCheckView> {
  late Size _screenSize;

  List<List<FpSampInfo>> _sampListList = [[], []];
  static List<DateTime> _rxStartDtList = [
    DateTime.now(),
    DateTime.now(),
  ];

  Timer? _timRecvCheck; // 受信チェックタイマ

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // UDP受信開始
    // UdpCom.startRx();
    // TCP接続
    TcpCom.connect();

    // 受信チェックタイマ停止
    _timRecvCheck?.cancel();
    // 1秒ごとの処理
    // _timRecvCheck = Timer.periodic(Duration(seconds: 1), (timer) async {
    _timRecvCheck = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      // サンプリングデータ取得
      // _sampListList = UdpCom.gegSampList();
      // _rxStartDtList = UdpCom.getRxStartDtList();
      _sampListList = TcpCom.gegSampList();
      _rxStartDtList = TcpCom.getRxStartDtList();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // 受信チェックタイマ停止
    _timRecvCheck?.cancel();
    // UDP受信停止
    // UdpCom.stoptRx();
    // TCP切断
    TcpCom.disconnectTcp();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 画面サイズを取得する
    _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _appBarWidget(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: _bodyWidget2(),
      ),
    );
  }

  Widget _bodyWidget() {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              FpFChartWidget(
                key: UniqueKey(),
                sampList: _sampListList[0],
                startAt: _rxStartDtList[0],
              ),
              FpMChartWidget(
                key: UniqueKey(),
                sampList: _sampListList[0],
                startAt: _rxStartDtList[0],
              ),
              FpCOPChartWidget(
                key: UniqueKey(),
                sampList: _sampListList[0],
                startAt: _rxStartDtList[0],
              ),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: [
              FpFChartWidget(
                key: UniqueKey(),
                sampList: _sampListList[1],
                startAt: _rxStartDtList[1],
              ),
              FpMChartWidget(
                key: UniqueKey(),
                sampList: _sampListList[1],
                startAt: _rxStartDtList[1],
              ),
              FpCOPChartWidget(
                key: UniqueKey(),
                sampList: _sampListList[1],
                startAt: _rxStartDtList[1],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bodyWidget2() {
    return Row(
      children: [
        _gaugeBar(true),
        Expanded(
          child: FpCOPSetChartWidget(
            key: UniqueKey(),
            sampList1: _sampListList[0],
            sampList2: _sampListList[1],
            startAt: _rxStartDtList[0],
          ),
        ),
        _gaugeBar(false),
      ],
    );
  }

  Widget _gaugeBar(bool isLeft) {
    var Fz1 = 0.0;
    var Fz2 = 0.0;
    var rate = 0.0;

    if (_sampListList.isNotEmpty) {
      if (_sampListList[0].isNotEmpty && _sampListList[1].isNotEmpty) {
        Fz1 = _sampListList[0].last.Fz;
        Fz2 = _sampListList[1].last.Fz;
      }
    }

    if (Fz1 > 10 || Fz2 > 10) {
      rate = isLeft ? Fz1 / (Fz1 + Fz2) : Fz2 / (Fz1 + Fz2);
    }

    String title = isLeft ? 'left' : 'right';

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: 100,
              child: RotatedBox(
                quarterTurns: -1,
                child: LinearProgressIndicator(
                  value: rate,
                  valueColor: AlwaysStoppedAnimation(Colors.red),
                  backgroundColor: Colors.grey,
                ),
              ),
            ),
          ),
          Text(title)
        ],
      ),
    );
    return Transform.rotate(
      angle: -pi / 2,
      child: LinearProgressIndicator(
        value: 0.5,
        valueColor: AlwaysStoppedAnimation(Colors.red),
        backgroundColor: Colors.grey,
      ),
    );
  }

  AppBar _appBarWidget() {
    return AppBar(
      centerTitle: true,
      title: Text('バランスチェック'),
      actions: [
        IconButton(
          icon: Icon(Icons.restart_alt),
          onPressed: () async {
            // ローディング表示開始
            EasyLoading.show();

            // ゼロリセット送信
            await TcpCom.sendReset();

            // ローディング表示終了
            EasyLoading.dismiss();

            Util.showMessageSnackBar(context, 'ゼロリセットしました');
          },
        ),
        // IconButton(
        //   icon: Icon(Icons.delete),
        //   onPressed: () {
        //     // サンプリングデータクリア
        //     // UdpCom.clearSampList();
        //     TcpCom.clearSampList();
        //   },
        // ),
      ],
    );
  }
}
