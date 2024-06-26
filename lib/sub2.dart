import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class DataModel {
  List<String> receivedData = [];
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String multicastAddress = '234.5.6.7';
  // final int port = 5400;
  final int port = 58433;

  late InternetAddress multicastGroup;
  late RawDatagramSocket socket;
  List<int> targetPattern1 = [85, 170, 170, 85]; // パターン1
  List<int> receivedData = [];

  List<ChartData> chartData1 = [];
  List<ChartData> chartData2 = [];

  late RawDatagramSocket udpSocket;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    multicastGroup = InternetAddress(multicastAddress);
    setupSocket();
    startDataProcessing();
    // initUdp();
  }

  @override
  void dispose() {
    udpSocket.close();
    timer.cancel();
    chartData1.clear();
    chartData2.clear();
    super.dispose();
  }



  void initUdp() async {
    udpSocket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);

    udpSocket.joinMulticast(
      InternetAddress(multicastAddress),
    );

    udpSocket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        Datagram dg = udpSocket.receive()!;
        List<int> data = dg.data;
        receivedData.addAll(data);

      }
    });

    // 例：1秒ごとに更新
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      // 受信したデータを setState で更新
      setState(() {

      });
    });
  }

  void setupSocket() async {
    socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      port,
      reuseAddress: true,
      reusePort: true,
    );
    socket.joinMulticast(multicastGroup);

    print('受信開始...');
  }

  void startDataProcessing() {
    Timer.periodic(Duration(milliseconds: 100), (timer) {
      processReceivedData();
    });
  }

  void processReceivedData() {
    Datagram? datagram = socket.receive();
    if (datagram != null) {
      List<int> data = datagram.data;
      receivedData.addAll(data);

      // // パターン1が含まれるか確認
      // int foundIndex = findPatternIndex(receivedData, targetPattern1);

      // // FP
      // while (foundIndex != -1 && receivedData.length >= foundIndex + 16) {
      //   // 16バイト分のデータを抜き出す
      //   List<int> extractedData = receivedData.sublist(foundIndex, foundIndex + 16);
      //
      //   print('抜き出されたデータ: $extractedData');
      //   print('受信データ長さ: ${receivedData.length}');
      //
      //   // 5バイト目以降を元の値に変換
      //   List<double> convertedValues = convertToOriginalValues(extractedData.sublist(4));
      //
      //   print('電圧データ: $convertedValues');
      //
      //   // グラフデータに追加
      //   chartData1.add(
      //       ChartData(
      //           chartData1.length.toDouble(),
      //           convertedValues[0] * 1000,
      //           convertedValues[1] * 1000,
      //           convertedValues[2] * 1000
      //       )
      //   );
      //   chartData2.add(
      //       ChartData(
      //           chartData2.length.toDouble(),
      //           convertedValues[3] * 100,
      //           convertedValues[4] * 100,
      //           convertedValues[5] * 100
      //       )
      //   );
      //   // for (int i = 0; i < convertedValues.length; i++) {
      //   //   if (i < 3) {
      //   //     chartData1.add(ChartData(
      //   //         chartData1.length.toDouble(),
      //   //         convertedValues[i],
      //   //     ));
      //   //   } else {
      //   //     chartData2.add(ChartData(chartData2.length.toDouble(), convertedValues[i]));
      //   //   }
      //   // }
      //
      //
      //
      //   // パターン1と抜き出されたデータをクリア
      //   receivedData.removeRange(0, foundIndex + 16);
      //
      //   // パターン1がまだ他にも含まれるか確認
      //   foundIndex = findPatternIndex(receivedData, targetPattern1);
      // }

      // MS
      while (receivedData.length >= 99) {
        // 16バイト分のデータを抜き出す
        List<int> extractedData = receivedData.sublist(0, 99);

        print('抜き出されたデータ: $extractedData');
        print('受信データ長さ: ${receivedData.length}');

        // MS 加速度パケット抜き出し 変換
        List<double> convertedValues = convertToOriginalValues2(extractedData.sublist(21, 33));

        print('電圧データ: $convertedValues');

        // グラフデータに追加
        chartData1.add(
            ChartData(
                chartData1.length.toDouble(),
                convertedValues[0],
                convertedValues[1],
                convertedValues[2]
            )
        );
        // chartData2.add(
        //     ChartData(
        //         chartData2.length.toDouble(),
        //         convertedValues[3] * 100,
        //         convertedValues[4] * 100,
        //         convertedValues[5] * 100
        //     )
        // );

        // パターン1と抜き出されたデータをクリア
        receivedData.removeRange(0, 99);
      }
    }
    // グラフを再描画
    setState(() {});
  }

  void processReceivedData2() {
    // パターン1が含まれるか確認
    int foundIndex = findPatternIndex(receivedData, targetPattern1);

    while (foundIndex != -1 && receivedData.length >= foundIndex + 16) {
      // 16バイト分のデータを抜き出す
      List<int> extractedData = receivedData.sublist(foundIndex, foundIndex + 16);

      print('抜き出されたデータ: $extractedData');
      print('受信データ長さ: ${receivedData.length}');

      // 5バイト目以降を元の値に変換
      List<double> convertedValues = convertToOriginalValues(extractedData.sublist(4));

      print('電圧データ: $convertedValues');

      // グラフデータに追加
      chartData1.add(
          ChartData(
              chartData1.length.toDouble(),
              convertedValues[0] * 1000,
              convertedValues[1] * 1000,
              convertedValues[2] * 1000
          )
      );
      chartData2.add(
          ChartData(
              chartData2.length.toDouble(),
              convertedValues[3] * 100,
              convertedValues[4] * 100,
              convertedValues[5] * 100
          )
      );

      // // グラフを再描画
      // setState(() {});

      // パターン1と抜き出されたデータをクリア
      receivedData.removeRange(0, foundIndex + 16);

      // パターン1がまだ他にも含まれるか確認
      foundIndex = findPatternIndex(receivedData, targetPattern1);

    }
  }

  int findPatternIndex(List<int> data, List<int> pattern) {
    for (int i = 0; i <= data.length - pattern.length; i++) {
      if (_isPatternMatch(data, i, pattern)) {
        return i;
      }
    }
    return -1; // パターンが見つからない場合
  }

  bool _isPatternMatch(List<int> data, int startIndex, List<int> pattern) {
    for (int i = 0; i < pattern.length; i++) {
      if (data[startIndex + i] != pattern[i]) {
        return false;
      }
    }
    return true;
  }

  List<double> convertToOriginalValues(List<int> bytes) {
    List<double> values = [];
    for (int i = 0; i < bytes.length; i += 2) {
      // 1. 2つの8ビットの整数を16ビットに結合
      int combinedValue = combineTo16Bit(bytes[i], bytes[i + 1]);

      // 2. 結合された16ビットの2の補数を符号付き整数に変換
      int signedValue = convertToSignedInt(combinedValue, 16);

      // 3. 電圧に変換
      double volt = signedValue * 10 / 32767;

      values.add(volt);
    }
    return values;
  }

  // 2つの8ビットの整数を16ビットに結合する関数
  int combineTo16Bit(int num1, int num2) {
    return ((num1 & 0xFF) << 8) | (num2 & 0xFF);
  }

  // 16ビットの2の補数を符号付き整数に変換する関数
  int convertToSignedInt(int value, int bits) {
    int signBitMask = 1 << (bits - 1);
    if ((value & signBitMask) != 0) {
      // 負の数の場合は2の補数を計算
      return value - (1 << bits);
    } else {
      return value;
    }
  }

  List<double> convertToOriginalValues2(List<int> bytes) {
    List<double> values = [];
    for (int i = 0; i < bytes.length; i += 4) {
      // 1. 2つの8ビットの整数を16ビットに結合
      int combinedValue = combineTo32Bit(bytes[i], bytes[i + 1], bytes[i + 2], bytes[i + 3]);

      // 単精度浮動小数点数に変換
      double result = int32ToFloat32(combinedValue);

      values.add(result);
    }
    return values;
  }

  // 4つの8ビットの整数を32ビットに結合する関数
  int combineTo32Bit(int num1, int num2, int num3, int num4) {
    return (num1 & 0xFF) << 24 | (num2 & 0xFF) << 16 | (num3 & 0xFF) << 8 | (num4 & 0xFF);
  }

  double int32ToFloat32(int value) {
    // 32ビットの2の補数を単精度浮動小数点数に変換
    var buffer = ByteData(4);
    buffer.setInt32(0, value, Endian.little);
    return buffer.getFloat32(0, Endian.little);
  }


  @override
  Widget build(BuildContext context) {
    processReceivedData2();

    return Scaffold(
      appBar: AppBar(
        title: Text('フォースプレートグラフ'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              primaryXAxis: NumericAxis(),
              primaryYAxis: NumericAxis(),
              series: <LineSeries<ChartData, double>>[
                LineSeries<ChartData, double>(
                  dataSource: chartData1,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y1,
                ),
                LineSeries<ChartData, double>(
                  dataSource: chartData1,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y2,
                ),
                LineSeries<ChartData, double>(
                  dataSource: chartData1,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y3,
                ),
              ],
            ),
          ),
          // Expanded(
          //   child: SfCartesianChart(
          //     primaryXAxis: NumericAxis(),
          //     primaryYAxis: NumericAxis(),
          //     series: <LineSeries<ChartData, double>>[
          //       LineSeries<ChartData, double>(
          //         dataSource: chartData2,
          //         xValueMapper: (ChartData data, _) => data.x,
          //         yValueMapper: (ChartData data, _) => data.y1,
          //       ),
          //       LineSeries<ChartData, double>(
          //         dataSource: chartData2,
          //         xValueMapper: (ChartData data, _) => data.x,
          //         yValueMapper: (ChartData data, _) => data.y2,
          //       ),
          //       LineSeries<ChartData, double>(
          //         dataSource: chartData2,
          //         xValueMapper: (ChartData data, _) => data.x,
          //         yValueMapper: (ChartData data, _) => data.y3,
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class ChartData {
  final double x;
  final double y1;
  final double y2;
  final double y3;

  ChartData(this.x, this.y1, this.y2, this.y3);
}

// void main() async {
//   final String multicastAddress = '234.5.6.7'; // マルチキャストアドレス
//   final int port = 5400; // ポート番号
//
//   // マルチキャストグループに参加
//   InternetAddress multicastGroup = InternetAddress(multicastAddress);
//   RawDatagramSocket socket = await RawDatagramSocket.bind(
//     InternetAddress.anyIPv4,
//     port,
//     reuseAddress: true,
//     reusePort: true,
//   );
//   socket.joinMulticast(multicastGroup);
//
//   print('受信開始...');
//
//   List<int> receiveList = [];
//   List<int> targetPattern = [85, 170, 170, 85];
//
//   void processReceivedData() {
//     // パターンが含まれるか確認
//     int foundIndex = findPatternIndex(receiveList, targetPattern);
//
//
//     while (foundIndex != -1 && receiveList.length >= foundIndex + 16) {
//       // 16バイト分のデータを抜き出す
//       List<int> extractedData = receiveList.sublist(foundIndex, foundIndex + 16);
//
//       print('抜き出されたデータ: $extractedData');
//       print('受信データ長さ: ${receiveList.length}');
//
//       // 5バイト目以降を元の値に変換
//       List<double> convertedValues = convertToOriginalValues(extractedData.sublist(4));
//
//       print('電圧データ: $convertedValues');
//
//
//       // パターン1と抜き出されたデータをクリア
//       receiveList.removeRange(0, foundIndex + 16);
//
//       // パターン1がまだ他にも含まれるか確認
//       foundIndex = findPatternIndex(receiveList, targetPattern);
//
//     }
//   }
//
//   // データを非同期で受信
//   socket.listen((RawSocketEvent event) {
//     if (event == RawSocketEvent.read) {
//       Datagram? datagram = socket.receive();
//       if (datagram != null) {
//         // String message = utf8.decode(datagram.data);
//         List message = datagram.data;
//         print('受信: $message');
//
//         receiveList.addAll(datagram.data);
//
//         // 受信データが更新されたらパターンの確認を行う
//         processReceivedData();
//       }
//     }
//   });
//
//
// }
//
// int findPatternIndex(List data, List<int> pattern) {
//   for (int i = 0; i <= data.length - pattern.length; i++) {
//     if (ListEquality().equals(data.sublist(i, i + pattern.length), pattern)) {
//       return i;
//     }
//   }
//   return -1; // パターンが見つからない場合
// }
//
//   List<double> convertToOriginalValues(List<int> bytes) {
//     List<double> values = [];
//     for (int i = 0; i < bytes.length; i += 2) {
//       // 1. 2つの8ビットの整数を16ビットに結合
//       int combinedValue = combineTo16Bit(bytes[i], bytes[i + 1]);
//
//       // 2. 結合された16ビットの2の補数を符号付き整数に変換
//       int signedValue = convertToSignedInt(combinedValue, 16);
//
//       // 3. 電圧に変換
//       double volt = signedValue * 10 / 32767;
//
//       values.add(volt);
//     }
//     return values;
//   }
//
//   // 2つの8ビットの整数を16ビットに結合する関数
//   int combineTo16Bit(int num1, int num2) {
//     return ((num1 & 0xFF) << 8) | (num2 & 0xFF);
//   }
//
//   // 16ビットの2の補数を符号付き整数に変換する関数
//   int convertToSignedInt(int value, int bits) {
//     int signBitMask = 1 << (bits - 1);
//     if ((value & signBitMask) != 0) {
//       // 負の数の場合は2の補数を計算
//       return value - (1 << bits);
//     } else {
//       return value;
//     }
//   }
