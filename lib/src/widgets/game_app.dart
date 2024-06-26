import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:block001/model/fp_samp_info.dart';
import 'package:block001/model/tcp_com.dart';
import 'package:block001/src/widgets/timer_card.dart';
import 'package:block001/view/top_view.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

import '../brick_breaker.dart';
import '../components/bat.dart';
import '../config.dart';
import 'overlay_screen.dart';
import 'score_card.dart';

import 'dart:async';
import 'dart:math' as math;

class GameApp extends StatefulWidget {

  // const GameApp({super.key});
  GameApp({
    Key? key,
    required this.mode,
  }) : super(key: key);

  final String mode;
  // @override
  // State<GameApp> createState() => _GameAppState();

  @override
  _GameApp createState() => _GameApp();

  static const String pageName = '/game-view';
  static const String pageName2 = '/game-view2';

  // 画面遷移
  static Future<Object?> pushPage(BuildContext context) async {
    var retVal = await Navigator.of(context).pushNamed(pageName);
    return Future.value(retVal);
  }

  // 画面遷移
  static Future<Object?> pushPage2(BuildContext context) async {
    var retVal = await Navigator.of(context).pushNamed(pageName2);
    return Future.value(retVal);
  }
}

class _GameApp extends State<GameApp> {
  late final BrickBreaker game;


  // List<List<FpSampInfo>> _sampListList = [[], []];
  // static List<DateTime> _rxStartDtList = [
  //   DateTime.now(),
  //   DateTime.now(),
  // ];

  Timer? _timRecvCheck; // 受信チェックタイマ
  String _mode = 'normal'; // ブロック崩し種類

  @override
  void initState() {
    super.initState();
    game = BrickBreaker();

    _mode = widget.mode;
    if (_mode == 'time') {
      game.timeMode = true;
    } else {
      game.timeMode = false;
    }

    // TCP接続
    TcpCom.connect();

    // 受信チェックタイマ停止
    _timRecvCheck?.cancel();
    // 1秒ごとの処理
    // _timRecvCheck = Timer.periodic(Duration(seconds: 1), (timer) async {
    _timRecvCheck = Timer.periodic(Duration(milliseconds: 200), (timer) async {
      // サンプリングデータ取得
      sampListList = TcpCom.gegSampList();
      // _rxStartDtList = TcpCom.getRxStartDtList();
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    // 受信チェックタイマ停止
    _timRecvCheck?.cancel();

    // TCP切断
    TcpCom.disconnectTcp();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xffa9d6e5),
                Color(0xfff2e8cf),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ScoreCard(score: game.score),
                        if (_mode == 'time') TimeCard(time: game.remainingTime),
                      ],
                    ),
                    Expanded(
                      child: FittedBox(
                        child: SizedBox(
                          width: gameWidth,
                          height: gameHeight,
                          child: GameWidget(
                            game: game,
                            overlayBuilderMap: {
                              PlayState.welcome.name: (context, games) =>
                                  Center(
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: gameWidth,
                                            padding: EdgeInsets.symmetric(horizontal: 50),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                if (sampListList[0].isNotEmpty && sampListList[1].isNotEmpty) {
                                                  // ローディング表示開始
                                                  EasyLoading.show();

                                                  // ゼロリセット送信
                                                  await TcpCom.sendReset();

                                                  // ローディング表示終了
                                                  EasyLoading.dismiss();
                                                }

                                                await game.delayGame();
                                                game.startGame();
                                              },
                                              child: Text(
                                                'ゲームスタート',
                                                style: TextStyle(
                                                  fontSize: 90,
                                                  // fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              PlayState.gameOver.name: (context, games) =>
                                  Center(
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: gameWidth,
                                            padding: EdgeInsets.symmetric(horizontal: 50),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                await game.delayGame();
                                                game.startGame();
                                              },
                                              child: Text(
                                                'もう一度遊ぶ',
                                                style: TextStyle(
                                                  fontSize: 100,
                                                  // fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Container(
                                            width: gameWidth,
                                            padding: EdgeInsets.symmetric(horizontal: 50),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                // ローディング表示開始
                                                EasyLoading.show();

                                                // TCP接続終了
                                                await TcpCom.disconnectTcp();

                                                // ローディング表示終了
                                                EasyLoading.dismiss();

                                                Navigator.push(
                                                  context,
                                                  new MaterialPageRoute<bool>(
                                                      builder: (BuildContext context) => TopView()
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                '最初に戻る',
                                                style: TextStyle(
                                                  fontSize: 100,
                                                  // fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              PlayState.won.name: (context, games) =>
                                  Center(
                                    child: Container(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: gameWidth,
                                            padding: EdgeInsets.symmetric(horizontal: 50),
                                            child: ElevatedButton(
                                              onPressed: () async {
                                                await game.delayGame();
                                                game.startGame();
                                              },
                                              child: Text(
                                                'もう一度遊ぶ',
                                                style: TextStyle(
                                                  fontSize: 100,
                                                  // fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 20,),
                                          Container(
                                            width: gameWidth,
                                            padding: EdgeInsets.symmetric(horizontal: 50),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  new MaterialPageRoute<bool>(
                                                      builder: (BuildContext context) => TopView()
                                                  ),
                                                );
                                              },
                                              child: Text(
                                                '最初に戻る',
                                                style: TextStyle(
                                                  fontSize: 100,
                                                  // fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
}
