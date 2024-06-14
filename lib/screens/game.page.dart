import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CoOrdValue {
  final int x;
  final int y;
  final int position;
  const CoOrdValue({required this.x, required this.y, required this.position});
  toJsonString() {
    return {'x': x, 'y': y, 'position': position};
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
  final List<String> combinations = [
    '012',
    '048',
    '036',
    '147',
    '246',
    '258',
    '345',
    '678'
  ];
  List<CoOrdValue> coordValues = <CoOrdValue>[];

  int position(int x, int y) {
    return (3 * x) + y;
  }

  addCoOrd(int x, int y) {
    setState(() {
      coordValues.add(CoOrdValue(x: x, y: y, position: position(x, y)));
    });
    // remove first
    if (coordValues.length == 4) {
      setState(() {
        coordValues.removeAt(0);
      });
    }
    final positionCombo = coordValues.map((el) => el.position).toList();
    for (var element in combinations) {
      List<int> arr = element.split("").map((el) => int.parse(el)).toList();
      if (unOrdDeepEq(positionCombo, arr)) {
        if (kDebugMode) {
          print('win');
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final boxSide = screenWidth / 3;
    return SafeArea(
      child: SizedBox(
        height: screenHeight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
              3,
              (int x) => Row(
                    children: List.generate(
                        3,
                        (int y) => Container(
                              height: boxSide,
                              width: boxSide,
                              padding: const EdgeInsets.all(4),
                              child: Card(
                                margin: const EdgeInsets.all(0),
                                shape: const BeveledRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: InkWell(
                                  onTap: () {
                                    addCoOrd(x, y);
                                  },
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(4)),
                                  child: Ink(
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4))),
                                    child: Center(
                                        child: coordValues.any((element) =>
                                                element.x == x &&
                                                element.y == y)
                                            ? Text("X",
                                                style: TextStyle(
                                                    color: coordValues.length ==
                                                                3 &&
                                                            coordValues[0].x ==
                                                                x &&
                                                            coordValues[0].y ==
                                                                y
                                                        ? Colors.white24
                                                        : Colors.white))
                                            : null),
                                  ),
                                ),
                              ),
                            )),
                  )),
        ),
      ),
    );
  }
}
