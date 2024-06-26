import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

import 'package:udp/udp.dart';

import 'package:block001/model/util.dart';
import 'package:block001/model/fp_samp_info.dart';

// UDPパケット受信状態
enum UdpRxState {
  Idle, // アイドル
  RxHead, // ヘッダ受信中
  RxBody, // 本体受信中
}

// UDP通信部
class UdpCom {
  static StreamSubscription<Datagram?>? _streamSubscription_Udp_Data1;
  static StreamSubscription<Datagram?>? _streamSubscription_Udp_Data2;
  static UDP? _udpReceiver1;
  static UDP? _udpReceiver2;

  static List<UdpRxState> _rxStateList = [
    UdpRxState.Idle,
    UdpRxState.Idle,
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
    _rxStateList[0] = UdpRxState.Idle;
    _rxStateList[1] = UdpRxState.Idle;
  }

  // static UDP? _udpReceiver_Relay;
  // static UDP? _udpReceiver_Uni;
  // static Map<String, int> _hrBuffMap = {}; // センサID:心拍数
  // static Map<String, bool> _batBuffMap = {}; // センサID:バッテリー状態
  // static Map<String, SensInfo> _sensMap = {};
  // static Map<String, int> _cntRecvMap = {}; // 受信カウンタ
  //
  // // 受信カウンタ取得
  // static Map<String, int> getRecvMap() {
  //   return _cntRecvMap;
  // }
  //
  // // 受信バッファ取得
  // static Map<String, int> getHrBuffMap() {
  //   Map<String, int> clone = {..._hrBuffMap};
  //   _hrBuffMap.clear();
  //
  //   return clone;
  // }
  //
  // // 受信バッファ取得
  // static Map<String, bool> getBatBuffMap() {
  //   Map<String, bool> clone = {..._batBuffMap};
  //   _batBuffMap.clear();
  //
  //   return clone;
  // }

  // データ受信処理
  static void _receiveData(Uint8List rxDataList, int index) {
    for (int i = 0; i < rxDataList.length; i++) {
      int data = rxDataList[i];

      switch (_rxStateList[index]) {
        // アイドル
        case UdpRxState.Idle:
          if (data == 0x55) {
            _rxBuffList[index].clear();
            _rxBuffList[index].add(data);
            // ヘッダ受信中へ遷移する
            _rxStateList[index] = UdpRxState.RxHead;
          }
          break;

        // ヘッダ受信中
        case UdpRxState.RxHead:
          if (_rxBuffList[index].length == 1 ||
              _rxBuffList[index].length == 2) {
            if (data == 0xAA) {
              _rxBuffList[index].add(data);
            } else {
              _rxBuffList[index].clear();
              // アイドルへ遷移する
              _rxStateList[index] = UdpRxState.Idle;
              print('[UDP] パケット受信エラー2:${index}');
            }
          } else if (_rxBuffList[index].length == 3) {
            if (data == 0x55) {
              _rxBuffList[index].add(data);
              // 本体受信中へ遷移する
              _rxStateList[index] = UdpRxState.RxBody;
            } else {
              _rxBuffList[index].clear();
              // アイドルへ遷移する
              _rxStateList[index] = UdpRxState.Idle;
              print('[UDP] パケット受信エラー3:${index}');
            }
          }
          break;

        // 本体受信中
        case UdpRxState.RxBody:
          _rxBuffList[index].add(data);
          if (_rxBuffList[index].length >= 16) {
            // パケット受信処理
            _receivePacket(index);
            _rxBuffList[index].clear();
            // アイドルへ遷移する
            _rxStateList[index] = UdpRxState.Idle;
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

    sampItem.Fx = rxData.getInt16(4) as double;
    sampItem.Fy = rxData.getInt16(6) as double;
    sampItem.Fz = rxData.getInt16(8) as double;
    sampItem.Mx = rxData.getInt16(10) as double;
    sampItem.My = rxData.getInt16(12) as double;
    sampItem.Mz = rxData.getInt16(14) as double;
    // sampItem.IDNum = rxData.getUint8(16);
    // sampItem.syncLine = rxData.getUint8(17);
    //
    // if (sampItem.Fx.abs() > 20000 ||
    //     sampItem.Fy.abs() > 20000 ||
    //     sampItem.Fz.abs() > 20000) {
    //   return;
    // }

    if (_sampListList.length == 0) {
      _rxStartDtList[index] = DateTime.now();
    }
    _sampListList[index].add(sampItem);
  }

  // UDP受信開始
  static Future<void> startRx() async {
    logger.info('[UDP] UDP受信開始');

    // _hrBuffMap.clear();
    // _batBuffMap.clear();
    // _sensMap.clear();
    // _cntRecvMap.clear();

    _sampListList[0].clear();
    _sampListList[1].clear();

    for (int retryCnt1 = 0; retryCnt1 < 3; retryCnt1++) {
      try {
        await _streamSubscription_Udp_Data1?.cancel();
        _udpReceiver1?.close();

        // MULTICAST
        // var multicastEndpoint =
        //     Endpoint.multicast(InternetAddress("234.5.6.7"), port: Port(5432));
        // var multicastEndpoint =
        //     Endpoint.multicast(InternetAddress("234.5.6.7"), port: Port(5400));
        // // var multicastEndpoint =
        // //     Endpoint.multicast(InternetAddress("234.5.6.7"), port: Port(5401));
        //
        // _udpReceiver1 = await UDP.bind(multicastEndpoint);

        // UNICAST
        var unicastEndpoint =
            Endpoint.unicast(InternetAddress.anyIPv4, port: Port(5400));
        _udpReceiver1 = await UDP.bind(unicastEndpoint);

        _streamSubscription_Udp_Data1 =
            _udpReceiver1!.asStream().listen((datagram) {
          if (datagram != null) {
            print('[UDP1 受信] 受信データサイズ:' + datagram.data.length.toString());

            // データ受信処理
            _receiveData(datagram.data, 0);
            print('[UDP1 受信] 受信パケット ${_sampListList[0].length}');
          }
        });
        break;
      } catch (ex) {
        print('***** エラー：UDPマルチキャスト1');
        print(ex);
        await Future.delayed(Duration(milliseconds: 300));
      }
    }

    for (int retryCnt2 = 0; retryCnt2 < 3; retryCnt2++) {
      try {
        await _streamSubscription_Udp_Data2?.cancel();
        _udpReceiver2?.close();

        // // MULTICAST
        // var multicastEndpoint =
        //     Endpoint.multicast(InternetAddress("234.5.6.7"), port: Port(5401));
        // _udpReceiver2 = await UDP.bind(multicastEndpoint);

        // UNICAST
        var unicastEndpoint =
            Endpoint.unicast(InternetAddress.anyIPv4, port: Port(5401));
        _udpReceiver2 = await UDP.bind(unicastEndpoint);

        _streamSubscription_Udp_Data2 =
            _udpReceiver2!.asStream().listen((datagram) {
          if (datagram != null) {
            print('[UDP2 受信] 受信データサイズ:' + datagram.data.length.toString());

            // データ受信処理
            _receiveData(datagram.data, 1);
            print('[UDP2 受信] 受信パケット ${_sampListList[1].length}');
          }
        });
        break;
      } catch (ex) {
        print('***** エラー：UDPマルチキャスト2');
        print(ex);
        await Future.delayed(Duration(milliseconds: 300));
      }
    }

    // var sender = await UDP.bind(Endpoint.any());
    //
    // List<int> txData = [];
    // // send a simple string to a broadcast endpoint on port 65001.
    // var dataLength = await sender.send("Hello World!".codeUnits,
    //     Endpoint.unicast(InternetAddress("192.168.24.193"), port: Port(5500)));

    // stdout.write("$dataLength bytes sent.");
  }

  // UDP受信停止
  static Future<void> stoptRx() async {
    logger.info('[UDP] UDP受信停止');

    await _streamSubscription_Udp_Data1?.cancel();
    await _streamSubscription_Udp_Data2?.cancel();
    _udpReceiver1?.close();
    _udpReceiver2?.close();
    _sampListList[0].clear();
    _sampListList[1].clear();
  }
}
