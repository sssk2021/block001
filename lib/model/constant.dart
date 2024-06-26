import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// import 'package:riverpod/riverpod.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:block001/model/util.dart';

const String g_appVer = '0.0.1';
const String g_buildVer = '0.0.1';

// const bool isRelease = const bool.fromEnvironment('dart.vm.product');
// const bool isRelease = true;
// 再実行した時に記録が継続される機能を無効にするフラグ
const bool disFlag_ResetCont = true;
// const bool disFlag_ResetCont = false;
// Firebaseを無効にするフラグ
// const bool disFlag_Firebase = true;
const bool disFlag_Firebase = false;

bool g_freeLicenseFlag = true; // フリーライセンスフラグ
bool g_liceseDispFlag = true; // ライセンス有効期限警告表示フラグ
DateTime? g_liceseLimitAt;  // ライセンス有効期限
String g_teamID = '';

const int g_SnackBarDurationSec = 3; // スナックバー表示時間

final Color g_primaryColor = Color(0xFF002F6C);
final Color g_primaryColor_back = Color(0xFF002F6C).withOpacity(0.3);
final Color g_backgroundColor = Colors.grey.shade200;

const double g_maxScreenWidth = 400;

// const Color g_backColor = Color(0xFFE8E7EC);
const Color g_backColor = Color(0xFFEAE9EF);
// const Color g_textColor = Color(0xFF707070);
const Color g_textColor = Color(0xFF2C2C2C);
// const Color g_iconColor = Color(0xFF707070);
const Color g_iconColor = Color(0xFF4B3B3B);
// Color g_lineColor = Color(0xFF343434).withOpacity(0.3);
const Color g_buttonColor = Color(0xFF065093);
const Color g_buttonBackColor = Color(0xFF8097B6);
const Color g_backColor2 = Color(0xFF4D6D98);

const Color g_backColor0 = Color(0xFF0175C2);

// final RouteObserver<PageRoute> g_routeObserver = RouteObserver<PageRoute>();

// const Color g_colorZone1 = Color(0xCAD0D6);
// const Color g_colorZone2 = Color(0x8CD4EF);
// const Color g_colorZone3 = Color(0x2BAE71);
// const Color g_colorZone4 = Color(0xEAC922);
// const Color g_colorZone5 = Color(0xF24040);

// const Color g_colorZone1 = Colors.grey;
// const Color g_colorZone2 = Colors.lightBlueAccent;
// const Color g_colorZone3 = Colors.green;
// const Color g_colorZone4 = Colors.amber;
// const Color g_colorZone5 = Colors.deepOrange;
