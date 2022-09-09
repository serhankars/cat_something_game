import 'dart:async';
import 'dart:math';

import 'package:cat_something_game/services/dogs_positioning_service.dart';
import 'package:cat_something_game/services/game_service.dart';
import 'package:cat_something_game/services/mouse_positioning_service.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../services/cat_positioning_service.dart';
import '../widgets/cat.dart';
import '../widgets/dog.dart';
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
  double _screenWidth = 0;
  double _screenHeight = 0;
  int _totalMouseCatched = 0;

  late AnimationController _othersAnimationContoller;

  late Timer _othersTimer;
  late Timer _collisionControlTimer;
  late int _numberOfDogs;
  Random random = Random();

  void _onTapDown(TapDownDetails details) {
    double targetAlignmentX =
        (details.globalPosition.dx - (_screenWidth / 2)) / (_screenWidth / 2);
    double targetAlignmentY =
        (details.globalPosition.dy - (_screenHeight / 2)) / (_screenHeight / 2);

    Provider.of<CatPositioningService>(context, listen: false)
        .setTargetAlignment(Alignment(targetAlignmentX, targetAlignmentY));

    Provider.of<GameService>(context, listen: false).isGameStarted = true;
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
    });

    Provider.of<GameService>(context, listen: false).isGameStarted = false;
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
    if (!Provider.of<GameService>(context, listen: false).isGameStarted) return;

    Alignment currentCatAlignment =
        Provider.of<CatPositioningService>(context, listen: false)
            .getCurrentAlignment();

    Alignment currentMouseAlignment =
        Provider.of<MousePositioningService>(context, listen: false)
            .getCurrentAlignment();

    List<Alignment> prevAlignmentOfDogs =
        Provider.of<DogsPositioningService>(context, listen: false)
            .previousAlignmentsList;
    List<Alignment> nextAlignmentOfDogs =
        Provider.of<DogsPositioningService>(context, listen: false)
            .nextAlignmentsList;

    for (int i = 0; i < _numberOfDogs; i++) {
      Alignment currentDogAlignment = AlignmentTween(
              begin: prevAlignmentOfDogs[i], end: nextAlignmentOfDogs[i])
          .evaluate(_othersAnimationContoller);

      if ((currentCatAlignment.x - currentDogAlignment.x).abs() < 0.04 &&
          (currentCatAlignment.y - currentDogAlignment.y).abs() < 0.04) {
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
    _numberOfDogs =
        Provider.of<GameService>(context, listen: false).numberOfDogs;

    int durationBetweenPointsForDogs =
        Provider.of<GameService>(context, listen: false)
            .durationBetweenPointsForKillers;

    _othersAnimationContoller = AnimationController(
        vsync: this, duration: Duration(seconds: durationBetweenPointsForDogs));
    super.initState();

    Provider.of<DogsPositioningService>(context, listen: false)
        .initializeDogsPositions(_numberOfDogs, _othersAnimationContoller);

    _othersTimer = Timer.periodic(
        Duration(seconds: durationBetweenPointsForDogs), (timer) {
      if (!Provider.of<GameService>(context, listen: false).isGameStarted) {
        return;
      }

      Provider.of<DogsPositioningService>(context, listen: false)
          .updateDogsTargets();

      Provider.of<MousePositioningService>(context, listen: false)
          .resetTarget();
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
              for (int i = 0; i < _numberOfDogs; i++)
                Dog(
                  dogIndex: i,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
