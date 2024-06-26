import 'package:block001/src/brick_breaker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OverlayScreen extends StatelessWidget {
  const OverlayScreen({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    if (title == 'TAP TO PLAY') {
      return Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {

                },
                child: Text(
                  'ゲームスタート',
                  style: TextStyle(
                      fontSize: 100,
                      // fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (title == 'G A M E   O V E R') {
      return Container(
        child: Column(
          children: [

          ],
        ),
      );
    } else if (title == 'Y O U   W O N ! ! !') {
      return Container(
        child: Column(
          children: [

          ],
        ),
      );
    } else {
      return Container();
    }
    return Container(
      alignment: const Alignment(0, -0.15),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge,
          ).animate().slideY(duration: 750.ms, begin: -3, end: 0),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.headlineSmall,
          )
              .animate(onPlay: (controller) => controller.repeat())
              .fadeIn(duration: 1.seconds)
              .then()
              .fadeOut(duration: 1.seconds),
          ElevatedButton(
            onPressed: () {},
            child: Text('TOP'),
          ),
        ],
      ),
    );
  }
}
