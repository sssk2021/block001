import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:block001/src/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

import 'package:block001/model/util.dart';
import 'package:block001/model/fp_samp_info.dart';

// TCPパケット受信状態
enum TcpRxState {
  Idle, // アイドル
  RxHead, // ヘッダ受信中
  RxBody, // 本体受信中
}

// TCP通信部
class TcpCom {
  static Socket? _socket1;
  static Socket? _socket2;
  static StreamSubscription<Uint8List>? _subscTcp1;
  static StreamSubscription<Uint8List>? _subscTcp2;

  static List<TcpRxState> _rxStateList = [
    TcpRxState.Idle,
    TcpRxState.Idle,
  ];

  static List<List<int>> _rxBuffList = [
    [],
    [],
  ];

  static List<List<FpSampInfo>> _sampListList = [
    [],
    [],
  ];

  static List<DateTime> _rxStartDtList = [
    DateTime.now(),
    DateTime.now(),
  ];

  static List<DateTime> getRxStartDtList() {
    return _rxStartDtList;
  }

  // サンプリングデータ取得
  static List<List<FpSampInfo>> gegSampList() {
    return _sampListList;
  }

  // サンプリングデータクリア
  static void clearSampList() {
    _sampListList[0].clear();
    _sampListList[1].clear();
    _rxStateList[0] = TcpRxState.Idle;
    _rxStateList[1] = TcpRxState.Idle;
  }

  // データ受信処理
  static void _receiveData(Uint8List rxDataList, int index) {
    for (int i = 0; i < rxDataList.length; i++) {
      int data = rxDataList[i];

      switch (_rxStateList[index]) {
        // アイドル
        case TcpRxState.Idle:
          if (data == 0x55) {
            _rxBuffList[index].clear();
            _rxBuffList[index].add(data);
            // ヘッダ受信中へ遷移する
            _rxStateList[index] = TcpRxState.RxHead;
          }
          break;

        // ヘッダ受信中
        case TcpRxState.RxHead:
          if (_rxBuffList[index].length == 1 ||
              _rxBuffList[index].length == 2) {
            if (data == 0xAA) {
              _rxBuffList[index].add(data);
            } else {
              _rxBuffList[index].clear();
              // アイドルへ遷移する
              _rxStateList[index] = TcpRxState.Idle;
              print('[UDP] パケット受信エラー2:${index}');
            }
          } else if (_rxBuffList[index].length == 3) {
            if (data == 0x55) {
              _rxBuffList[index].add(data);
              // 本体受信中へ遷移する
              _rxStateList[index] = TcpRxState.RxBody;
            } else {
              _rxBuffList[index].clear();
              // アイドルへ遷移する
              _rxStateList[index] = TcpRxState.Idle;
              print('[UDP] パケット受信エラー3:${index}');
            }
          }
          break;

        // 本体受信中
        case TcpRxState.RxBody:
          _rxBuffList[index].add(data);
          if (_rxBuffList[index].length >= 16) {
            // パケット受信処理
            _receivePacket(index);
            _rxBuffList[index].clear();
            // アイドルへ遷移する
            _rxStateList[index] = TcpRxState.Idle;
          }
          // else if (_rxBuffList[index].length >= 8) {
          //   int lastIndex = _rxBuffList[index].length - 1;
          //   if (_rxBuffList[index][lastIndex - 3] == 0x55 &&
          //       _rxBuffList[index][lastIndex - 2] == 0xAA &&
          //       _rxBuffList[index][lastIndex - 1] == 0xAA &&
          //       _rxBuffList[index][lastIndex] == 0x55) {
          //     _rxBuffList[index].clear();
          //     // アイドルへ遷移する
          //     _rxStateList[index] = UdpRxState.Idle;
          //   }
          // }
          break;

        default:
          break;
      }
    }
  }

  // パケット受信処理
  static void _receivePacket(int index) {
    // logger.info('[UDP] パケット受信処理:${index} ${_sampListList[index].length}');

    // バイナリデータに変換する
    ByteData rxData =
        ByteData.sublistView(Uint8List.fromList(_rxBuffList[index]));

    FpSampInfo sampItem = FpSampInfo();

    List<double> convertedValues = convertToOriginalValues(_rxBuffList[index].sublist(4));
    // sampItem.Fx = rxData.getInt16(4);
    // sampItem.Fy = rxData.getInt16(6);
    // sampItem.Fz = rxData.getInt16(8);
    // sampItem.Mx = rxData.getInt16(10);
    // sampItem.My = rxData.getInt16(12);
    // sampItem.Mz = rxData.getInt16(14);
    sampItem.Fx = convertedValues[1] * 1000;
    sampItem.Fy = convertedValues[0] * -1000;
    sampItem.Fz = convertedValues[2] * 1000;
    sampItem.Mx = convertedValues[4] * 100;
    sampItem.My = convertedValues[3] * -100;
    sampItem.Mz = convertedValues[5] * 100;
    // sampItem.IDNum = rxData.getUint8(16);
    // sampItem.syncLine = rxData.getUint8(17);
    //
    // if (sampItem.Fx.abs() > 20000 ||
    //     sampItem.Fy.abs() > 20000 ||
    //     sampItem.Fz.abs() > 20000) {
    //   return;
    // }

    if (_sampListList[index].length == 0) {
      _rxStartDtList[index] = DateTime.now();
    } else {
      sampItem.rxCnt = _sampListList[index].last.rxCnt + 1;
    }
    _sampListList[index].add(sampItem);
    // if (_sampListList[index].length > 1000 * 30 * 1) {
    if (_sampListList[index].length > 1000 * 1 * 1) {
      _sampListList[index].removeAt(0);
    }
  }

  // TCP接続
  static Future<void> connect() async {
    logger.info('TCP接続->開始');

    // // システム情報取得(キャッシュ)
    // DbSystemInfo systemItem = DbSystemMng.getSystemItem_Cashe();

    _sampListList[0].clear();
    _sampListList[1].clear();

    try {
      // _socket = await Socket.connect('192.168.1.10', 58432);
      _socket1 = await Socket.connect(ipAddress, 5600);

      // 受信開始
      _subscTcp1 = _socket1!.listen((event) {
        // print('event:' + event.length.toString());
        // パケット受信処理
        _receiveData(event, 0);
        logger.info('[TCP1] 受信完了 ${_sampListList[0].length}');
      });
    } catch (ex) {
      print(ex.toString());
      // throw Exception('connect error!!');
    }

    try {
      // _socket = await Socket.connect('192.168.1.10', 58432);
      _socket2 = await Socket.connect(ipAddress, 5601);

      // 受信開始
      _subscTcp2 = _socket2!.listen((event) {
        // print('event:' + event.length.toString());
        // パケット受信処理
        _receiveData(event, 1);
        logger.info('[TCP2] 受信完了 ${_sampListList[1].length}');
      });
    } catch (ex) {
      print(ex.toString());
      // throw Exception('connect error!!');
    }

    logger.info('TCP接続->終了');
  }

  // TCP切断
  static Future<void> disconnectTcp() async {
    logger.info('TCP切断->開始');

    await _subscTcp1?.cancel();
    await _subscTcp2?.cancel();
    await _socket1?.close();
    await _socket2?.close();

    _sampListList[0].clear();
    _sampListList[1].clear();

    logger.info('TCP切断->終了');
  }

  // ゼロリセット送信
  static Future<void> sendReset() async {
    logger.info('ゼロリセット送信->開始');
    Socket socket = await Socket.connect(ipAddress, 7700);

    await Future.delayed(Duration(seconds: 2));
    List<int> txData = [
      0x4F,
      0x53,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30,
      0x30,
      0x43,
      0x32,
      0x0D,
    ];

    socket.add(txData);
    await socket.flush();

    await Future.delayed(Duration(seconds: 2));

    await socket.close();

    logger.info('ゼロリセット送信->終了');
  }

  static List<double> convertToOriginalValues(List<int> bytes) {
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
  static int combineTo16Bit(int num1, int num2) {
    return ((num1 & 0xFF) << 8) | (num2 & 0xFF);
  }

  // 16ビットの2の補数を符号付き整数に変換する関数
  static int convertToSignedInt(int value, int bits) {
    int signBitMask = 1 << (bits - 1);
    if ((value & signBitMask) != 0) {
      // 負の数の場合は2の補数を計算
      return value - (1 << bits);
    } else {
      return value;
    }
  }
}
