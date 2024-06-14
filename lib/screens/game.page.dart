import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infinite_tic_tac_toe/constants.dart';
import 'package:infinite_tic_tac_toe/enums.dart';

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

  int position(int x, int y) {
    return (3 * x) + y;
  }

  addCoOrd(int x, int y, TicTacType val) {
    setState(() {
      coordValues.add(CoOrdValue(position: position(x, y), value: val));
      newValue = val == TicTacType.x ? TicTacType.o : TicTacType.x;
    });
    // remove first of type if length is more than 3
    if (coordValues
            .where(
              (element) => element.value == val,
            )
            .length ==
        4) {
      final targetValues =
          coordValues.where((element) => element.value == val).toList();
      setState(() {
        coordValues.remove(targetValues.first);
      });
    }
    // check win condiotion for selected value
    checkWin(val);
  }

  checkWin(TicTacType val) {
    final positionCombo = coordValues
        .where((el) => el.value == val)
        .map((el) => el.position)
        .toList();
    for (var element in Constants.combinations) {
      List<int> arr = element.split("").map((el) => int.parse(el)).toList();
      if (unOrdDeepEq(positionCombo, arr)) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("win ${val.name}")));
        setState(() {
          coordValues = [];
        });
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final boxSide = screenWidth / 3;
    final brightness = MediaQuery.of(context).platformBrightness;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent, statusBarBrightness: brightness),
      child: SafeArea(
        child: Scaffold(
          body: SizedBox(
            height: screenHeight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (int x) {
                return Row(
                  children: List.generate(3, (int y) {
                    final placeValue = coordValues.firstWhereOrNull(
                        (element) => position(x, y) == element.position);
                    var isLastOfKind = false;
                    if (coordValues
                            .where(
                              (element) => element.value == placeValue?.value,
                            )
                            .length ==
                        3) {
                      isLastOfKind = position(x, y) ==
                          coordValues
                              .firstWhereOrNull(
                                (element) => element.value == placeValue?.value,
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
                            borderRadius: BorderRadius.all(Radius.circular(4))),
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
                                    ? Text(placeValue.value.name,
                                        style: TextStyle(
                                            color: isLastOfKind
                                                ? Colors.white24
                                                : Colors.white))
                                    : null),
                          ),
                        ),
                      ),
                    );
                  }),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
