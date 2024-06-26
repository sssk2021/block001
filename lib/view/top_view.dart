import 'package:block001/src/config.dart';
import 'package:block001/src/widgets/game_app.dart';
import 'package:block001/src/widgets/score_list_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';

// import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:community_material_icon/community_material_icon.dart';

import 'package:block001/model/constant.dart';
import 'package:block001/model/util.dart';
import 'package:block001/view/com_check_view.dart';

class TopView extends ConsumerStatefulWidget {
  TopView({Key? key}) : super(key: key);

  @override
  _TopView createState() => _TopView();

  static const String pageName = '/top-view';

  // 画面遷移
  static Future<Object?> pushPage(BuildContext context) async {
    var retVal = await Navigator.of(context).pushNamed(pageName);
    return Future.value(retVal);
  }
}

class _TopView extends ConsumerState<TopView> {
  late Size _screenSize;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // // 画面サイズを取得する
    // _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _appBarWidget(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: _bodyWidget(),
      ),
    );
  }

  Widget _bodyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 300,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          new MaterialPageRoute<bool>(
                            builder: (BuildContext context) => GameApp(mode: 'normal')
                          ),
                        );
                        setState(() {

                        });
                        // GameApp.pushPage(context);
                      },
                      child: Text(
                        'フリーモード',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 30,),
                Expanded(
                  child: Container(
                    height: 300,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          new MaterialPageRoute<bool>(
                              builder: (BuildContext context) => GameApp(mode: 'time')
                          ),
                        );
                        // GameApp.pushPage2(context);
                      },
                      child: Text(
                        'タイムトライアル',
                        style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20,),
          // ScoreListCard(scoreList1: scoreList),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(10, 20, 10, 40),
          //   child: Row(
          //     children: [
          //       Expanded(
          //         child: Container(
          //           height: 100,
          //           // width: double.infinity,
          //           child: ElevatedButton(
          //             onPressed: () {
          //
          //             },
          //             child: Text(
          //               '設定',
          //               style: TextStyle(
          //                   fontSize: 30,
          //                   fontWeight: FontWeight.bold
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //       SizedBox(width: 30,),
          //       Expanded(
          //         child: Container(
          //           height: 100,
          //           // width: double.infinity,
          //           child: ElevatedButton(
          //             onPressed: () {
          //
          //             },
          //             child: Text(
          //               'キャリブレーション',
          //               style: TextStyle(
          //                   fontSize: 30,
          //                   fontWeight: FontWeight.bold
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    child: Center(
                      child: Text(
                        '1位',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    child: Text(
                      '${scoreList[0]} pt',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    child: Center(
                      child: Text(
                        '2位',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    child: Text(
                      '${scoreList[1]} pt',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    child: Center(
                      child: Text(
                        '3位',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 200,
                    child: Text(
                      '${scoreList[2]} pt',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 40),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 100,
                    // width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ComCheckView.pushPage(context);
                      },
                      child: Text(
                        'バランスチェック',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // FilledButton(
          //   child: Text('通信確認テスト'),
          //   onPressed: () {
          //     ComCheckView.pushPage(context);
          //   },
          // ),
          // SizedBox(height: 20,),
          // FilledButton(
          //   child: Text('ブロック崩し'),
          //   onPressed: () {
          //     GameApp.pushPage(context);
          //   },
          // ),
        ],
      ),
    );
  }

  AppBar _appBarWidget() {
    return AppBar(
      title: Text(''),
      backgroundColor: g_backColor0,
      actions: [
        IconButton(
          icon: const Icon(
            Icons.settings,
            color: g_backColor0,
          ),
          tooltip: 'setting',
          onPressed: () {
            Util.showLevelDialog(context);
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.settings,
            // color: g_backColor0,
          ),
          tooltip: 'IP',
          onPressed: () {
            Util.showIPDialog(context);
          },
        ),
      ],
    );
  }
}
