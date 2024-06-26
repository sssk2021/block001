import 'package:flutter/material.dart';

import '../brick_breaker.dart';
import '../config.dart';

class ScoreListCard extends StatelessWidget {
  const ScoreListCard({
    super.key,
    required this.scoreList1,
  });

  final ValueNotifier<List<int>> scoreList1;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<int>>(
      valueListenable: scoreList1,
      builder: (context, scoreList, child) {
        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  child: Center(
                    child: Text(
                      '1位',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  child: Text(
                    '${scoreList[0]} pt',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  child: Center(
                    child: Text(
                      '2位',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  child: Text(
                    '${scoreList[1]} pt',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 200,
                  child: Center(
                    child: Text(
                      '3位',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 200,
                  child: Text(
                    '${scoreList[2]} pt',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
