import 'package:flutter/material.dart';

const brickColors = [
  Color(0xfff94144),
  Color(0xfff3722c),
  Color(0xfff8961e),
  Color(0xfff9844a),
  Color(0xfff9c74f),
  Color(0xff90be6d),
  Color(0xff43aa8b),
  Color(0xff4d908e),
  Color(0xff277da1),
  Color(0xff577590),
];

const gameWidth = 820.0;
const gameHeight = 1600.0;
const ballRadius = gameWidth * 0.02;
const batWidth = gameWidth * 0.2;
const batHeight = ballRadius * 2;
const batStep = gameWidth * 0.05;
const brickGutter = gameWidth * 0.015;
// final brickWidth =
//     (gameWidth - (brickGutter * (brickColors.length + 1))) / brickColors.length;
double brickWidth =
    (gameWidth - (brickGutter * (brockNum + 1))) / brockNum;
const brickHeight = gameHeight * 0.03;
const difficultyModifier = 1.03;

int brockNum = 10;
int barHeight = 1;
// final ValueNotifier<List<int>> scoreList = ValueNotifier([0, 0, 0]);
final List<int> scoreList = [0, 0, 0];
String ipAddress = '192.168.24.193';