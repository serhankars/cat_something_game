import 'dart:async';
import 'dart:math';

import 'package:cat_something_game/services/game_services.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

class GamePage extends StatefulWidget {
  static const String route = "/game";

  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  Alignment _oldAlignmentCat = const Alignment(0, 0);
  Alignment _nextAlignmentCat = const Alignment(0, 0);

  List<Alignment> _previousAlignmentsOfKillers = [];
  List<Alignment> _nextAlignmentsOfKillers = [];
  double screenWidth = 0;
  double screenHeight = 0;
  late AnimationController _acCat;
  late AnimationController _acOthers;
  late Timer othersTimer;
  late int _numberOfKillers;
  Random random = Random();

  void _controlCollisions(Timer timer) {
    Alignment currentCatAlignment =
        AlignmentTween(begin: _oldAlignmentCat, end: _nextAlignmentCat)
            .evaluate(_acCat);

    for (int i = 0; i < _numberOfKillers; i++) {
      Alignment currentKillerAlignment = AlignmentTween(
              begin: _previousAlignmentsOfKillers[i],
              end: _nextAlignmentsOfKillers[i])
          .evaluate(_acOthers);

      if ((currentCatAlignment.x - currentKillerAlignment.x).abs() < 0.04 &&
          (currentCatAlignment.y - currentKillerAlignment.y).abs() < 0.04) {
        debugPrint("KILLED!!!!");
      }
    }
  }

  double _generateRandomCoordinateAxisValue() {
    return (random.nextBool() ? -1 : 1) * random.nextDouble();
  }

  @override
  void initState() {
    _numberOfKillers =
        Provider.of<GameServices>(context, listen: false).numberOfKillers;
    int durationBetweenPointsForCat =
        Provider.of<GameServices>(context, listen: false)
            .durationBetweenPointsForCat;

    int durationBetweenPointsForKillers =
        Provider.of<GameServices>(context, listen: false)
            .durationBetweenPointsForKillers;

    _previousAlignmentsOfKillers = [
      for (int i = 0; i < _numberOfKillers; i++)
        Alignment(_generateRandomCoordinateAxisValue(),
            _generateRandomCoordinateAxisValue())
    ];

    _nextAlignmentsOfKillers = [..._previousAlignmentsOfKillers];

    _acCat = AnimationController(
        vsync: this, duration: Duration(seconds: durationBetweenPointsForCat));

    _acOthers = AnimationController(
        vsync: this,
        duration: Duration(seconds: durationBetweenPointsForKillers));
    super.initState();

    othersTimer = Timer.periodic(
        Duration(seconds: durationBetweenPointsForKillers), (timer) {
      setState(() {
        _previousAlignmentsOfKillers = _nextAlignmentsOfKillers;
        _nextAlignmentsOfKillers = [
          for (int i = 0; i < _numberOfKillers; i++)
            Alignment(_generateRandomCoordinateAxisValue(),
                _generateRandomCoordinateAxisValue())
        ];
      });
      _acOthers.reset();
      _acOthers.forward();
    });

    Timer.periodic(
        const Duration(
          milliseconds: 10,
        ),
        _controlCollisions);
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          double horizontalAlignment =
              (details.globalPosition.dx - (screenWidth / 2)) /
                  (screenWidth / 2);
          double verticalAlignment =
              (details.globalPosition.dy - (screenHeight / 2)) /
                  (screenHeight / 2);
          _oldAlignmentCat =
              AlignmentTween(begin: _oldAlignmentCat, end: _nextAlignmentCat)
                  .evaluate(_acCat);
          _nextAlignmentCat = Alignment(horizontalAlignment, verticalAlignment);
          _acCat.reset();
          _acCat.forward();

          setState(() {});
        },
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              colorFilter: ColorFilter.mode(Colors.grey, BlendMode.color),
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          constraints: const BoxConstraints.expand(),
          child: Stack(
            children: [
              AlignTransition(
                alignment: AlignmentTween(
                        begin: _oldAlignmentCat, end: _nextAlignmentCat)
                    .animate(_acCat),
                child: Image.asset(
                  "assets/images/cat.png",
                  width: 50,
                  height: 50,
                ),
              ),
              for (int i = 0; i < _numberOfKillers; i++)
                AlignTransition(
                  alignment: AlignmentTween(
                          begin: _previousAlignmentsOfKillers[i],
                          end: _nextAlignmentsOfKillers[i])
                      .animate(_acOthers),
                  child: Image.asset(
                    "assets/images/dog.png",
                    width: 50,
                    height: 50,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
