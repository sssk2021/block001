import 'package:block001/model/fp_samp_info.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../brick_breaker.dart';

class Bat extends PositionComponent
    with DragCallbacks, HasGameReference<BrickBreaker> {
  Bat({
    required this.cornerRadius,
    required super.position,
    required super.size,
  }) : super(
          anchor: Anchor.center,
          children: [RectangleHitbox()],
        );

  final Radius cornerRadius;

  final _paint = Paint()
    ..color = const Color(0xff1e6091)
    ..style = PaintingStyle.fill;

  @override
  void render(Canvas canvas) {
    // // 閾値あり
    // if (sampListList.isNotEmpty) {
    //   if (sampListList[0].isNotEmpty && sampListList[1].isNotEmpty) {
    //     var Fz1 = sampListList[0].last.Fz;
    //     var Fz2 = sampListList[1].last.Fz;
    //     moveBy2(Fz1, Fz2);
    //   }
    // }

    // 通常
    if (sampListList.isNotEmpty) {
      if (sampListList[0].isNotEmpty && sampListList[1].isNotEmpty) {
        var Fz1 = sampListList[0].last.Fz;
        var Fz2 = sampListList[1].last.Fz;
        if (Fz1 > 20.0 || Fz2 > 20.0) {
          if (Fz2 - Fz1 > 20) {
            moveBy(10);
          } else if (Fz1 - Fz2 > 20) {
            moveBy(-10);
          }
        }
      }
    }

    if (xAxis == 1) {
      moveBy(10);
    } else if (xAxis == -1) {
      moveBy(-10);
    }

    super.render(canvas);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
          Offset.zero & size.toSize(),
          cornerRadius,
        ),
        _paint);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    position.x = (position.x + event.localDelta.x)
        .clamp(width / 2, game.width - width / 2);
  }

  void moveBy(double dx) {
    add(MoveToEffect(
      Vector2(
        (position.x + dx).clamp(width / 2, game.width - width / 2),
        position.y,
      ),
      EffectController(duration: 0.1),
    ));
  }

  void moveBy2(double Fz1, double Fz2) {
    if (Fz1 - Fz2 > 100) {
      add(MoveToEffect(
        Vector2(
          (position.x - 10).clamp(width / 2, game.width / 2),
          position.y,
        ),
        EffectController(duration: 0.1),
      ));
    } else if (Fz1 - Fz2 > 50) {
      add(MoveToEffect(
        Vector2(
          (position.x - 10).clamp(width / 2 + game.width / 6, game.width / 2),
          position.y,
        ),
        EffectController(duration: 0.1),
      ));
    } else if (Fz1 - Fz2 > 20) {
      add(MoveToEffect(
        Vector2(
          (position.x - 10).clamp(width / 2 + game.width / 3, game.width / 2),
          position.y,
        ),
        EffectController(duration: 0.1),
      ));
    }  else if (Fz1 - Fz2 < -100) {
      add(MoveToEffect(
        Vector2(
          (position.x + 10).clamp(game.width / 2, game.width - width / 2),
          position.y,
        ),
        EffectController(duration: 0.1),
      ));
    } else if (Fz1 - Fz2 < -50) {
      add(MoveToEffect(
        Vector2(
          (position.x + 10).clamp(game.width / 2, game.width * 5 / 6 - width / 2),
          position.y,
        ),
        EffectController(duration: 0.1),
      ));
    } else if (Fz1 - Fz2 < -20) {
      add(MoveToEffect(
        Vector2(
          (position.x + 10).clamp(game.width / 2, game.width * 2 / 3 - width / 2),
          position.y,
        ),
        EffectController(duration: 0.1),
      ));
    } else {
      add(MoveToEffect(
        Vector2(
          game.width / 2,
          position.y,
        ),
        EffectController(duration: 0.1),
      ));
    }

  }
}

int xAxis = 0;
List<List<FpSampInfo>> sampListList = [[], []];