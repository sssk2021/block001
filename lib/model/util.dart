import 'dart:io';

import 'package:block001/src/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:simple_logger/simple_logger.dart';
// import 'package:path_provider/path_provider.dart';

import 'package:block001/model/constant.dart';

final logger = SimpleLogger();

class Util {
  static Directory? _docDir;

  // static Future<void> init() async {
  //   logger.info('初期化->開始');
  //   _docDir = await getApplicationDocumentsDirectory();
  //   // print('ApplicationDocumentsDirectory:' + _docDir!.path);
  //   logger.info('初期化->終了:' + _docDir!.path);
  // }

  // ドキュメントパス取得
  static String getAppDocDirPath() {
    // logger.info('ドキュメントパス取得：' + _docDir!.path);
    return _docDir!.path;
  }

  // 曜日テキスト取得
  static String getWeekDayText(DateTime dt) {
    int index = dt.weekday; // 1が月曜日、7が日曜日です。
    const List<String> weekDayList = [
      "日",
      "月",
      "火",
      "水",
      "木",
      "金",
      "土",
      "日",
    ];
    if (index > 7) {
      print("indexエラー：" + index.toString());
    }
    return weekDayList[index];
  }

  // 特定の月の日数を取得するロジック
  static int getDayCountInMonth(DateTime date) {
    final firstDayThisMonth = DateTime(date.year, date.month, date.day);
    final firstDayNextMonth = DateTime(firstDayThisMonth.year,
        firstDayThisMonth.month + 1, firstDayThisMonth.day);
    return firstDayNextMonth.difference(firstDayThisMonth).inDays;
  }

  // 一週間分の日時リストを生成する
  static List<DateTime> getWeekList(DateTime dt) {
    List<DateTime> dtList = [];

    // DateTime dt = getLastSundayDataTime();
    for (int i = 0; i < 7; i++) {
      DateTime res = dt.add(Duration(days: i));
      dtList.add(res);
    }

    return dtList;
  }

  // 一ヶ月分の日時リストを生成する
  static List<DateTime> getMonthList(DateTime dt) {
    // List<DateTime> dtList = [];

    // final selectedDate = DateTime(2021, 11);
    final lastDateThisMonth =
        DateTime(dt.year, dt.month + 1, 1).subtract(const Duration(days: 1));
    final firstDateThisMonth = DateTime(dt.year, dt.month, 1);
    final targetMonthDateList = List<DateTime>.generate(lastDateThisMonth.day,
        (i) => firstDateThisMonth.add(Duration(days: i)));

    return targetMonthDateList;
  }

  // 直近の日曜日の日付を算出し、その日付を返す
  static DateTime getLastSundayDataTime(DateTime dResult) {
    initializeDateFormatting('ja');
    // DateTime dResult = DateTime.now();

    // 当日が日曜日ではないならば、
    // 直前の日曜日まで日付を戻していく
    if (dResult.weekday != DateTime.sunday) {
      for (int i = 0; i < 7; ++i) {
        dResult = dResult.subtract(Duration(days: 1));
        // 直近の未来の日曜日を求めたい場合は、下記のようにします。
        // dResult = dResult.add(Duration(days : 1));

        if (dResult.weekday == DateTime.sunday) {
          break;
        }
      }
    }

    return (dResult);
  }

  // インデックス->性別変換
  static String convIndexToSex(int index) {
    String ret;

    // 男性
    if (index == 0) {
      ret = "男性";
    }
    // 女性
    else if (index == 1) {
      ret = "女性";
    }
    // 未選択
    else {
      ret = "";
    }
    return ret;
  }

  // 性別->インデックス変換
  static int convSexToIndex(String sexText) {
    int ret;

    // 男性
    if (sexText == "男性") {
      ret = 0;
    }
    // 女性
    else if (sexText == "女性") {
      ret = 1;
    }
    // 未選択
    else {
      ret = -1;
    }
    return ret;
  }

  static DateTime getNowDate() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
  }

  static DateTime getNow() {
    return DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      DateTime.now().hour,
      DateTime.now().minute,
      DateTime.now().second,
    );
  }

  // 日付時間テキスト取得
  static String dateTimeToText(DateTime dt) {
    DateTime nowDt = DateTime.now();
    if (nowDt.year == dt.year &&
        nowDt.month == dt.month &&
        nowDt.day == dt.day) {
      return timeToText(dt);
    } else {
      return dateToText2(dt) + ' ' + timeToText(dt);
    }
  }

  // 日付テキスト取得
  static String dateToText(DateTime dt) {
    String ret = dt.year.toString() +
        '/' +
        dt.month.toString().padLeft(2, '0') +
        '/' +
        dt.day.toString().padLeft(2, '0');
    return ret;
  }

  // 日付テキスト取得
  static String dateToText2(DateTime dt) {
    String ret = dt.month.toString() + '/' + dt.day.toString().padLeft(2, '0');
    return ret;
  }

  // 時間テキスト取得
  static String timeToText(DateTime dt) {
    String ret =
        dt.hour.toString() + ':' + dt.minute.toString().padLeft(2, '0');
    return ret;
  }

  // 時間テキスト取得
  static String timeToText2(DateTime dt) {
    String ret = dt.hour.toString().padLeft(2, '0') +
        ':' +
        dt.minute.toString().padLeft(2, '0');
    return ret;
  }

  static String convTimeSecToTextHMS(int timeSec) {
    int hour = (timeSec / (60 * 60)).toInt();
    int min = ((timeSec - (hour * 60 * 60)) / 60).toInt();
    int sec = (timeSec - ((hour * 60 * 60) + (min * 60)));
    String timeText = "";

    timeText += hour.toString();
    timeText += ":";
    timeText += min.toString().padLeft(2, '0');
    timeText += ":";
    timeText += sec.toString().padLeft(2, '0');

    return timeText;
  }

  static String convTimeSecToTextHM(int timeSec) {
    int hour = (timeSec / (60 * 60)).toInt();
    int min = ((timeSec - (hour * 60 * 60)) / 60).toInt();
    // int sec = (timeSec - ((hour * 60 * 60) + (min * 60)));
    String timeText = "";

    timeText += hour.toString();
    timeText += ":";
    timeText += min.toString().padLeft(2, '0');
    // timeText += ":";
    // timeText += sec.toString().padLeft(2, '0');

    return timeText;
  }

  static String convTimeSecToText(int timeSec) {
    int min = (timeSec / 60).toInt();
    int sec = (timeSec - min * 60);
    String timeText = "";

    // timeText += min.toString().padLeft(2, '0');
    timeText += min.toString();
    timeText += ":";
    timeText += sec.toString().padLeft(2, '0');

    return timeText;
  }

  static String convTimeSecToText2(int timeSec) {
//    int hour = (timeSec / (60 * 60)).toInt();
    int min = ((timeSec) / 60).toInt();
    int sec = (timeSec - min * 60);
    String timeText = "";

    // timeText += hour.toString().padLeft(2, '0');
    // timeText += ":";
    timeText += min.toString().padLeft(2, '0');
    timeText += ":";
    timeText += sec.toString().padLeft(2, '0');

    return timeText;
  }

  static String convTimeSecToText3(int timeSec) {
    int hour = (timeSec / 60 / 60).toInt();
    int min = ((timeSec - hour * 60 * 60) / 60).toInt();
    int sec = (timeSec - min * 60);
    String timeText = "";

    if (hour > 0) {
      timeText += hour.toString();
      timeText += "時間";
    }
    timeText += min.toString();
    timeText += "分";
    // timeText += sec.toString().padLeft(2, '0');
    // timeText += "秒間";
    timeText += "間";

    return timeText;
  }

  // メッセージボックス表示(1ボタン)
  static Future<void> showAlearDialog1(
      BuildContext context, String title, String msg) async {
    logger.info("メッセージボックス表示(1ボタン)");
    bool? result = await showDialog<bool>(
      context: context,
      // ダイアログ表示時の背景をタップしたときにダイアログを閉じてよいかどうか
      // barrierDismissible: false,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                logger.info("OKボタンタップ");
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    print('dialog result: $result');
  }

  // メッセージボックス表示(2ボタン)
  static Future<bool> showAlearDialog2(
    BuildContext context,
    String title,
    String msg,
  ) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          // title: Text('確認'),
          title: Text(title),
          // content: Text('確認のダイアログです。'),
          content: Text(msg),
          actions: <Widget>[
            TextButton(
              // child: Text('Cancel'),
              child: Text('キャンセル'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    print('dialog result: $result');

    if (result == null) {
      return Future.value(false);
    } else {
      return Future.value(result);
    }
  }

  // スナックバーメッセージ表示
  static void showMessageSnackBar(
    BuildContext context,
    String msg,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: g_SnackBarDurationSec),
    ));
  }

  // メッセージボックス表示(1ボタン)
  static Future<void> showLevelDialog(
      BuildContext context) async {
    logger.info("メッセージボックス表示(1ボタン)");
    bool? result = await showDialog<bool>(
      context: context,
      // ダイアログ表示時の背景をタップしたときにダイアログを閉じてよいかどうか
      barrierDismissible: true,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(16),
          // title: Text('title'),
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                barHeight = 1;
                Navigator.of(context).pop();
              },
              child: Text(
                'かんたん',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                barHeight = 4;
                Navigator.of(context).pop();
              },
              child: Text(
                'ふつう',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                ),),
            ),
            SizedBox(height: 10,),
            ElevatedButton(
              onPressed: () {
                barHeight = 7;
                Navigator.of(context).pop();
              },
              child: Text(
                'むずかしい',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold
                ),),
            ),
          ],
        );
      },
    );

    print('dialog result: $result');
  }

  // メッセージボックス表示(2ボタン)
  static Future<bool> showIPDialog(
      BuildContext context,) async {
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        List<String> parts = ipAddress.split('.').map<String>((part) => part).toList();
        String ip1 = parts[0];
        String ip2 = parts[1];
        String ip3 = parts[2];
        String ip4 = parts[3];

        return AlertDialog(
          // title: Text('確認'),
          title: Text('IP設定'),
          // content: Text('確認のダイアログです。'),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 100,
                child: TextFormField(
                  initialValue: ip1.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (val) {
                    print(val);
                    if (val == '') {

                    } else {
                      ip1 = val;
                    }
                  },
                ),
              ),
              Text('.'),
              Container(
                width: 100,
                child: TextFormField(
                  initialValue: ip2.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (val) {
                    print(val);
                    if (val == '') {

                    } else {
                      ip2 = val;
                    }
                  },
                ),
              ),
              Text('.'),
              Container(
                width: 100,
                child: TextFormField(
                  initialValue: ip3.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (val) {
                    print(val);
                    if (val == '') {

                    } else {
                      ip3 = val;
                    }
                  },
                ),
              ),
              Text('.'),
              Container(
                width: 100,
                child: TextFormField(
                  initialValue: ip4.toString(),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (val) {
                    print(val);
                    if (val == '') {

                    } else {
                      ip4 = val;
                    }
                  },
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                ipAddress = '$ip1.$ip2.$ip3.$ip4';
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    print('dialog result: $result');

    if (result == null) {
      return Future.value(false);
    } else {
      return Future.value(result);
    }
  }
}
