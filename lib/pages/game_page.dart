import 'dart:math';

import 'package:cat_something_game/services/collision_service.dart';
import 'package:cat_something_game/services/dogs_positioning_service.dart';
import 'package:cat_something_game/services/game_service.dart';
import "package:flutter/material.dart";
import 'package:provider/provider.dart';

import '../services/cat_positioning_service.dart';
import '../widgets/cat.dart';
import '../widgets/dog.dart';
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

  late AnimationController _othersAnimationContoller;
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
            .durationBetweenPointsForDogs;

    _othersAnimationContoller = AnimationController(
        vsync: this, duration: Duration(seconds: durationBetweenPointsForDogs));

    Provider.of<DogsPositioningService>(context, listen: false)
        .initializeDogsPositions(_numberOfDogs, _othersAnimationContoller);

    Provider.of<GameService>(context, listen: false).initTimer(context);
    Provider.of<CollisionService>(context, listen: false).initTimer(context);

    super.initState();
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
