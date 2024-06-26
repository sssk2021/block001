import 'dart:async';
import 'dart:ffi';
import 'dart:math' as math;

import 'package:block001/view/top_view.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'components/components.dart';
import 'config.dart';

enum PlayState { welcome, playing, gameOver, won }

class BrickBreaker extends FlameGame
    with HasCollisionDetection, KeyboardEvents, TapDetector {
  BrickBreaker()
      : super(
          camera: CameraComponent.withFixedResolution(
            width: gameWidth,
            height: gameHeight,
          )
        );

  final ValueNotifier<int> score = ValueNotifier(0);
  final rand = math.Random();
  double get width => size.x;
  double get height => size.y;

  late PlayState _playState;
  PlayState get playState => _playState;
  set playState(PlayState playState) {
    _playState = playState;
    switch (playState) {
      case PlayState.welcome:
      case PlayState.gameOver:
      case PlayState.won:
        overlays.add(playState.name);
      case PlayState.playing:
        overlays.remove(PlayState.welcome.name);
        overlays.remove(PlayState.gameOver.name);
        overlays.remove(PlayState.won.name);
    }
  }

  late Timer countDown;
  late Timer countDown2;
  ValueNotifier<int> remainingTime = ValueNotifier(30);
  bool timerStarted = false;
  bool timeMode = false;
  bool scoreUpdate = true;

  late final TextComponent _text;
  int _count = 3;

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();

    countDown = Timer(1, onTick: () {
      if (timeMode) {
        if (remainingTime.value > 0) {
          --remainingTime.value;
        }
      }
    },repeat: true);

    countDown2 = Timer(1, onTick: () {
      if (_count > 0) {
        --_count;
      }
    },repeat: true);

    camera.viewfinder.anchor = Anchor.topLeft;

    world.add(PlayArea());

    playState = PlayState.welcome;

    _text = TextComponent(
      text: _count.toString(),
      position: Vector2(size.x * 0.5, size.y * 0.5),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: const TextStyle(
          fontSize: 64,
          color: Colors.black,
        ),
      ),
    );
  }

  Future<void> delayGame() async {
    if (playState == PlayState.playing) return;

    world.removeAll(world.children.query<Ball>());
    world.removeAll(world.children.query<Bat>());
    world.removeAll(world.children.query<Brick>());

    playState = PlayState.playing;
    score.value = 0;

    _count = 3;

    countDown2
      ..reset()
      ..start();

    // countDown2 = Timer(1, onTick: () {
    //   --_count;
    // },repeat: true);

    world.add(_text);

    await Future<void>.delayed(
      const Duration(seconds: 3),
    );

    countDown2.stop();

    world.removeAll(world.children.query<TextComponent>());
  }

  void startGame() {


    world.add(Ball(
        difficultyModifier: difficultyModifier,
        radius: ballRadius,
        position: size / 2,
        velocity: Vector2((rand.nextDouble() - 0.5) * width, height * 0.2)
            .normalized()
          ..scale(height / 4)));

    world.add(Bat(
        size: Vector2(batWidth, batHeight),
        cornerRadius: const Radius.circular(ballRadius / 2),
        // position: Vector2(width / 2, height * 0.95)
        position: Vector2(width / 2, height * (-0.05 * barHeight + 1))
    ));

    // 通常
    world.addAll([
      for (var i = 0; i < brockNum; i++)
        for (var j = 1; j <= 5; j++)
            Brick(
              Vector2(
                (i + 0.5) * brickWidth + (i + 1) * brickGutter,
                (j + 2.0) * brickHeight + j * brickGutter,
              ),
              brickColors[i],
            ),
    ]);

    // // 交互にまだら
    // world.addAll([
    //   for (var i = 0; i < brockNum; i++)
    //     for (var j = 1; j <= 5; j++)
    //       if ((i + j).isEven)
    //       Brick(
    //         Vector2(
    //           (i + 0.5) * brickWidth + (i + 1) * brickGutter,
    //           (j + 2.0) * brickHeight + j * brickGutter,
    //         ),
    //         brickColors[i],
    //       ),
    // ]);

    // // 奇数列のみ
    // world.addAll([
    //   for (var i = 0; i < brockNum; i++)
    //     for (var j = 1; j <= 5; j++)
    //       if (i.isOdd)
    //       Brick(
    //         Vector2(
    //           (i + 0.5) * brickWidth + (i + 1) * brickGutter,
    //           (j + 2.0) * brickHeight + j * brickGutter,
    //         ),
    //         brickColors[i],
    //       ),
    // ]);

    timerStarted = true;
    remainingTime = ValueNotifier(30);
    countDown
      ..reset()
      ..start();
    scoreUpdate = true;
  }


  @override
  void onTap() {
    super.onTap();
    paused = !paused;
    // startGame();
  }

  @override
  KeyEventResult onKeyEvent(
      RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    super.onKeyEvent(event, keysPressed);
    switch (event.logicalKey) {
      case LogicalKeyboardKey.arrowLeft:
        world.children.query<Bat>().first.moveBy(-batStep);
      case LogicalKeyboardKey.arrowRight:
        world.children.query<Bat>().first.moveBy(batStep);
      case LogicalKeyboardKey.space:
      case LogicalKeyboardKey.enter:
        startGame();
    }
    return KeyEventResult.handled;
  }

  void moveRight() {
    world.children.query<Bat>().first.moveBy(41);
  }

  void moveLeft() {
    world.children.query<Bat>().first.moveBy(-41);
  }

  @override
  Color backgroundColor() => const Color(0xfff2e8cf);

  @override
  void update(double dt) {
    super.update(dt);

    countDown2.update(dt);
    _text.text = _count.toString();

    if (timeMode) {
      if (timerStarted) {
        if (remainingTime.value > 0) {
          if (playState == PlayState.gameOver) {
            countDown.stop();
          } else {
            countDown.update(dt);
          }
        } else {
          add(RemoveEffect(
              delay: 0.35,
              onComplete: () {
                playState = PlayState.gameOver;
                timerStarted = false;
              }));
        }
      }
    }


    if (playState == PlayState.gameOver || playState == PlayState.won) {
      if (scoreUpdate) {
        scoreList.add(score.value);
        // リストをソートして上位3つの要素を残す
        scoreList.sort((a, b) => b.compareTo(a)); // 降順にソート
        if (scoreList.length > 3) {
          scoreList.removeRange(3, scoreList.length); // 上位3つの要素以外を削除
        }

        scoreUpdate = false;
        print(scoreList);

        // scoreList.value.add(score.value);
        // // リストをソートして上位3つの要素を残す
        // scoreList.value.sort((a, b) => b.compareTo(a)); // 降順にソート
        // if (scoreList.value.length > 3) {
        //   scoreList.value.removeRange(3, scoreList.value.length); // 上位3つの要素以外を削除
        // }
      }

    }
  }
}
