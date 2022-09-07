import 'dart:async';
import 'dart:math';

import 'package:cat_something_game/services/game_services.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../widgets/game_over_dialog.dart';

class GamePage extends StatefulWidget {
  static const String route = "/game";

  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  bool _isGameStarted = false;
  double _screenWidth = 0;
  double _screenHeight = 0;
  int _totalMouseCatched = 0;

  Alignment _oldAlignmentCat = const Alignment(0, 0);
  Alignment _nextAlignmentCat = const Alignment(0, 0);

  late Alignment _oldAlignmentMouse;
  late Alignment _nextAlignmentMouse;

  List<Alignment> _previousAlignmentsOfKillers = [];
  List<Alignment> _nextAlignmentsOfKillers = [];
  late AnimationController _catAnimationController;
  late AnimationController _othersAnimationContoller;

  late Timer _othersTimer;
  late Timer _collisionControlTimer;
  late int _numberOfKillers;
  Random random = Random();

  void _onTapDown(TapDownDetails details) {
    double horizontalAlignment =
        (details.globalPosition.dx - (_screenWidth / 2)) / (_screenWidth / 2);
    double verticalAlignment =
        (details.globalPosition.dy - (_screenHeight / 2)) / (_screenHeight / 2);
    _oldAlignmentCat =
        AlignmentTween(begin: _oldAlignmentCat, end: _nextAlignmentCat)
            .evaluate(_catAnimationController);
    _nextAlignmentCat = Alignment(horizontalAlignment, verticalAlignment);
    _catAnimationController.reset();
    _catAnimationController.forward();

    setState(() {
      if (!_isGameStarted) {
        _isGameStarted = true;
      }
    });
  }

  void _onMouseCatched() {
    setState(() {
      _totalMouseCatched++;
      _oldAlignmentMouse = Alignment(_generateRandomCoordinateAxisValue(),
          _generateRandomCoordinateAxisValue());
      _nextAlignmentMouse = _oldAlignmentMouse;
    });
  }

  void _endGame() {
    setState(() {
      _othersAnimationContoller.reset();
      _othersAnimationContoller.stop();
      _othersTimer.cancel();
      _collisionControlTimer.cancel();
      _oldAlignmentCat = const Alignment(0, 0);
      _nextAlignmentCat = const Alignment(0, 0);
      _isGameStarted = false;
    });

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
        AlignmentTween(begin: _oldAlignmentCat, end: _nextAlignmentCat)
            .evaluate(_catAnimationController);

    Alignment currentMouseAlignment =
        AlignmentTween(begin: _oldAlignmentMouse, end: _nextAlignmentMouse)
            .evaluate(_othersAnimationContoller);

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

  double _generateRandomCoordinateAxisValue() {
    return (random.nextBool() ? -1 : 1) * random.nextDouble();
  }

  @override
  void dispose() {
    _catAnimationController.dispose();
    _othersAnimationContoller.dispose();
    super.dispose();
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

    _oldAlignmentMouse = Alignment(_generateRandomCoordinateAxisValue(),
        _generateRandomCoordinateAxisValue());

    _nextAlignmentMouse = _oldAlignmentMouse;

    _catAnimationController = AnimationController(
        vsync: this, duration: Duration(seconds: durationBetweenPointsForCat));

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
            Alignment(_generateRandomCoordinateAxisValue(),
                _generateRandomCoordinateAxisValue())
        ];

        _oldAlignmentMouse = _nextAlignmentMouse;
        _nextAlignmentMouse = Alignment(_generateRandomCoordinateAxisValue(),
            _generateRandomCoordinateAxisValue());
      });
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
              AlignTransition(
                alignment: AlignmentTween(
                        begin: _oldAlignmentMouse, end: _nextAlignmentMouse)
                    .animate(_othersAnimationContoller),
                child: Image.asset(
                  "assets/images/mouse.png",
                  width: 50,
                  height: 50,
                ),
              ),
              AlignTransition(
                alignment: AlignmentTween(
                        begin: _oldAlignmentCat, end: _nextAlignmentCat)
                    .animate(_catAnimationController),
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
