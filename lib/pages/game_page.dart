import 'dart:async';
import 'dart:math';

import 'package:cat_something_game/services/game_services.dart';
import 'package:cat_something_game/services/mouse_positioning_service.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../helpers/positioning_helpers.dart';
import '../services/cat_positioning_service.dart';
import '../widgets/cat.dart';
import '../widgets/game_over_dialog.dart';
import '../widgets/mouse.dart';

class GamePage extends StatefulWidget {
  static const String route = "/game";

  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  bool _isGameStarted = false;
  double _screenWidth = 0;
  double _screenHeight = 0;
  int _totalMouseCatched = 0;

  List<Alignment> _previousAlignmentsOfKillers = [];
  List<Alignment> _nextAlignmentsOfKillers = [];
  late AnimationController _othersAnimationContoller;

  late Timer _othersTimer;
  late Timer _collisionControlTimer;
  late int _numberOfKillers;
  Random random = Random();

  void _onTapDown(TapDownDetails details) {
    double targetAlignmentX =
        (details.globalPosition.dx - (_screenWidth / 2)) / (_screenWidth / 2);
    double targetAlignmentY =
        (details.globalPosition.dy - (_screenHeight / 2)) / (_screenHeight / 2);

    Provider.of<CatPositioningService>(context, listen: false)
        .setTargetAlignment(Alignment(targetAlignmentX, targetAlignmentY));

    setState(() {
      if (!_isGameStarted) {
        _isGameStarted = true;
      }
    });
  }

  void _onMouseCatched() {
    setState(() {
      _totalMouseCatched++;
      Provider.of<MousePositioningService>(context, listen: false)
          .resetPosition();
    });
  }

  void _endGame() {
    setState(() {
      _othersAnimationContoller.reset();
      _othersAnimationContoller.stop();
      _othersTimer.cancel();
      _collisionControlTimer.cancel();
      _isGameStarted = false;
    });

    Provider.of<MousePositioningService>(context, listen: false).stopMovement();
    Provider.of<CatPositioningService>(context, listen: false)
        .resetCatPosition();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const GameOverDialog();
      },
    );
  }

  void _controlCollisions(Timer timer) {
    if (!_isGameStarted) return;

    Alignment currentCatAlignment =
        Provider.of<CatPositioningService>(context, listen: false)
            .getCurrentAlignment();

    Alignment currentMouseAlignment =
        Provider.of<MousePositioningService>(context, listen: false)
            .getCurrentAlignment();

    for (int i = 0; i < _numberOfKillers; i++) {
      Alignment currentKillerAlignment = AlignmentTween(
              begin: _previousAlignmentsOfKillers[i],
              end: _nextAlignmentsOfKillers[i])
          .evaluate(_othersAnimationContoller);

      if ((currentCatAlignment.x - currentKillerAlignment.x).abs() < 0.04 &&
          (currentCatAlignment.y - currentKillerAlignment.y).abs() < 0.04) {
        _endGame();
      }

      if ((currentCatAlignment.x - currentMouseAlignment.x).abs() < 0.04 &&
          (currentCatAlignment.y - currentMouseAlignment.y).abs() < 0.04) {
        _onMouseCatched();
      }
    }
  }

  @override
  void dispose() {
    _othersAnimationContoller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _numberOfKillers =
        Provider.of<GameServices>(context, listen: false).numberOfKillers;

    int durationBetweenPointsForKillers =
        Provider.of<GameServices>(context, listen: false)
            .durationBetweenPointsForKillers;

    _previousAlignmentsOfKillers = [
      for (int i = 0; i < _numberOfKillers; i++)
        PositioningHelpers.generateRandomAlignment()
    ];

    _nextAlignmentsOfKillers = [..._previousAlignmentsOfKillers];
    _othersAnimationContoller = AnimationController(
        vsync: this,
        duration: Duration(seconds: durationBetweenPointsForKillers));
    super.initState();

    _othersTimer = Timer.periodic(
        Duration(seconds: durationBetweenPointsForKillers), (timer) {
      if (!_isGameStarted) return;

      setState(() {
        _previousAlignmentsOfKillers = _nextAlignmentsOfKillers;
        _nextAlignmentsOfKillers = [
          for (int i = 0; i < _numberOfKillers; i++)
            PositioningHelpers.generateRandomAlignment()
        ];
      });

      Provider.of<MousePositioningService>(context, listen: false)
          .resetTarget();
      _othersAnimationContoller.reset();
      _othersAnimationContoller.forward();
    });

    _collisionControlTimer = Timer.periodic(
        const Duration(
          milliseconds: 10,
        ),
        _controlCollisions);
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTapDown: _onTapDown,
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
              const Mouse(),
              const Cat(),
              for (int i = 0; i < _numberOfKillers; i++)
                AlignTransition(
                  alignment: AlignmentTween(
                          begin: _previousAlignmentsOfKillers[i],
                          end: _nextAlignmentsOfKillers[i])
                      .animate(_othersAnimationContoller),
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
