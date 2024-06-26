import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:collection/collection.dart';

// import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:riverpod/riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:community_material_icon/community_material_icon.dart';

import 'package:block001/model/constant.dart';
import 'package:block001/model/util.dart';

class TempView extends ConsumerStatefulWidget {
  TempView({Key? key}) : super(key: key);

  @override
  _TempView createState() => _TempView();

  static const String pageName = '/temp-view';

  // 画面遷移
  static Future<Object?> pushPage(BuildContext context) async {
    var retVal = await Navigator.of(context).pushNamed(pageName);
    return Future.value(retVal);
  }
}

class _TempView extends ConsumerState<TempView> {
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
    // 画面サイズを取得する
    _screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: _appBarWidget(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: _bodyWidget(),
      ),
    );
  }

  Widget _bodyWidget() {
    return Column(
      children: [
        FilledButton(
          child: Text('test'),
          onPressed: () {},
        ),
        ElevatedButton(
          child: Text('テスト'),
          onPressed: () {},
        ),
        Text('abc'),
      ],
    );
  }

  AppBar _appBarWidget() {
    return AppBar(
      title: Text(''),
    );
  }
}
