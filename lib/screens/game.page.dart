import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:infinite_tic_tac_toe/constants.dart';
import 'package:infinite_tic_tac_toe/enums.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';

class CoOrdValue {
  final int position;
  final TicTacType value;
  const CoOrdValue({required this.position, required this.value});
  toJsonString() {
    return {'position': position, 'value': value.name};
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Function unOrdDeepEq = const DeepCollectionEquality.unordered().equals;
  List<CoOrdValue> coordValues = <CoOrdValue>[];
  TicTacType newValue = TicTacType.x;
  TicTacType? winner;
  double opac = 1;
  Timer? timer;
  final int deleteThreshold = 3;
  final AudioPlayer ticPlayer = AudioPlayer();
  final AudioPlayer tacPlayer = AudioPlayer();
  Map<TicTacType, int> scoreBoard = {TicTacType.x: 0, TicTacType.o: 0};

  int position(int x, int y) {
    return (3 * x) + y;
  }

  addCoOrd(int x, int y, TicTacType val) async {
    playSound(val);
    setState(() {
      coordValues.add(CoOrdValue(position: position(x, y), value: val));
      newValue = val == TicTacType.x ? TicTacType.o : TicTacType.x;
    });
    log('added ${val.name} to position:${position(x, y)}');
    // remove first of type if length is more than delete threshold
    if (coordValues
            .where(
              (element) => element.value == val,
            )
            .length ==
        deleteThreshold + 1) {
      final targetValues =
          coordValues.where((element) => element.value == val).toList();
      setState(() {
        coordValues.remove(targetValues.first);
      });
    }
    // check win condiotion for selected value
    checkWin(val);
  }

  checkWin(TicTacType val) async {
    final positionCombo = coordValues
        .where((el) => el.value == val)
        .map((el) => el.position)
        .toList();
    for (var element in Constants.combinations) {
      List<int> arr = element.split("").map((el) => int.parse(el)).toList();
      if (unOrdDeepEq(positionCombo, arr)) {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate();
        }
        setState(() {
          winner = val;
          scoreBoard.update(val, (prev) => prev + 1);
        });
        timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
          setState(() {
            opac = t.tick.isOdd ? 1 : 0;
          });
        });
        Future.delayed(const Duration(seconds: 3), () {
          timer?.cancel();
          setState(() {
            winner = null;
            coordValues = [];
          });
        });
        break;
      }
    }
  }

  IconData icon(TicTacType val) {
    if (val == TicTacType.x) {
      return FontAwesomeIcons.x;
    }
    return FontAwesomeIcons.o;
  }

  Color iconColor(TicTacType val) {
    if (val == TicTacType.x) {
      return Colors.red;
    }
    return Colors.blue;
  }

  playSound(TicTacType val) async {
    if (val == TicTacType.x) {
      await ticPlayer.stop();
      await ticPlayer.seek(Duration.zero);
      ticPlayer.play();
      return;
    }
    await tacPlayer.stop();
    await tacPlayer.seek(Duration.zero);
    tacPlayer.play();
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ticPlayer.setAsset(Constants.ticSound);
      await tacPlayer.setAsset(Constants.tacSound);
    });
    super.initState();
  }

  @override
  void dispose() {
    ticPlayer.dispose();
    tacPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final statusBarHeight = MediaQuery.of(context).viewPadding.top;
    final boxSide = screenWidth / 3;
    final brightness = MediaQuery.of(context).platformBrightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, statusBarBrightness: brightness),
      child: Scaffold(
        body: SafeArea(
          child: SizedBox(
            height: screenHeight,
            child: Column(
              children: [
                SizedBox(
                  height: ((screenHeight - screenWidth) / 2) - statusBarHeight,
                  child: LayoutBuilder(
                    builder: (context, constraints) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [TicTacType.x, TicTacType.o]
                          .asMap()
                          .map((key, value) => MapEntry(
                              key,
                              SizedBox(
                                width: screenWidth / 3,
                                child: Card(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Wrap(
                                      direction: Axis.vertical,
                                      runAlignment: WrapAlignment.center,
                                      spacing: constraints.maxHeight / 8,
                                      children: [
                                        Icon(
                                          icon(value),
                                          color: iconColor(value),
                                        ),
                                        Text(
                                          scoreBoard[value].toString(),
                                          style: const TextStyle(
                                              fontSize: 24.00,
                                              fontWeight: FontWeight.w800),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )))
                          .values
                          .toList(),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (int x) {
                    return Row(
                      children: List.generate(3, (int y) {
                        final placeValue = coordValues.firstWhereOrNull(
                            (element) => position(x, y) == element.position);
                        var isLastOfKind = false;
                        if (coordValues
                                .where(
                                  (element) =>
                                      element.value == placeValue?.value,
                                )
                                .length ==
                            deleteThreshold) {
                          isLastOfKind = position(x, y) ==
                              coordValues
                                  .firstWhereOrNull(
                                    (element) =>
                                        element.value == placeValue?.value,
                                  )
                                  ?.position;
                        }
                        return Container(
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
                                placeValue == null
                                    ? addCoOrd(x, y, newValue)
                                    : null;
                              },
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: Ink(
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4))),
                                child: Center(
                                    child: placeValue != null
                                        ? Icon(
                                            icon(placeValue.value),
                                            color: iconColor(placeValue.value)
                                                .withOpacity(
                                                    winner == placeValue.value
                                                        ? opac
                                                        : isLastOfKind
                                                            ? 0.6
                                                            : 1),
                                          )
                                        : null),
                              ),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
                ),
                SizedBox(
                  height: (screenHeight - screenWidth) / 2,
                  child: winner == null
                      ? Padding(
                          padding: const EdgeInsets.all(8.00),
                          child: Center(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  "Turn for: ",
                                  style: TextStyle(
                                      fontSize: 20.00,
                                      fontWeight: FontWeight.w800),
                                ),
                                Icon(
                                  icon(newValue),
                                  color: iconColor(newValue),
                                ),
                              ],
                            ),
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
