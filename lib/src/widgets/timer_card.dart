import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';

class TimeCard extends StatelessWidget {
  const TimeCard({
    super.key,
    required this.time,
  });

  final ValueNotifier<int> time;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: time,
      builder: (context, time, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 18),
          child: Text(
            'Time: ${time}',
            style: Theme.of(context).textTheme.titleLarge!,
          ),
        );
      },
    );
  }
}
