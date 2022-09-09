import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/game_over_dialog.dart';
import 'cat_positioning_service.dart';
import 'dogs_positioning_service.dart';
import 'game_service.dart';
import 'mouse_positioning_service.dart';

class CollisionService extends ChangeNotifier {
  late BuildContext context;
  late Timer collisionControlTimer;

  void initTimer(BuildContext contextParam) {
    context = contextParam;
    collisionControlTimer = Timer.periodic(
        const Duration(
          milliseconds: 30,
        ),
        _controlCollisions);
  }

  void _controlCollisions(Timer timer) {
    DogsPositioningService dogsPositioningService =
        Provider.of<DogsPositioningService>(context, listen: false);
    GameService gameService = Provider.of<GameService>(context, listen: false);

    if (!gameService.isGameStarted) return;
    int numberOfDogs = gameService.numberOfDogs;

    Alignment currentCatAlignment =
        Provider.of<CatPositioningService>(context, listen: false)
            .getCurrentAlignment();

    Alignment currentMouseAlignment =
        Provider.of<MousePositioningService>(context, listen: false)
            .getCurrentAlignment();

    List<Alignment> prevAlignmentOfDogs =
        dogsPositioningService.previousAlignmentsList;
    List<Alignment> nextAlignmentOfDogs =
        dogsPositioningService.nextAlignmentsList;

    for (int i = 0; i < numberOfDogs; i++) {
      Alignment currentDogAlignment = AlignmentTween(
              begin: prevAlignmentOfDogs[i], end: nextAlignmentOfDogs[i])
          .evaluate(dogsPositioningService.dogsAnimationController);

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

  void _onMouseCatched() {
    Provider.of<GameService>(context, listen: false).onMouseCatched();
    Provider.of<MousePositioningService>(context, listen: false)
        .resetPosition();
  }

  void _endGame() {
    collisionControlTimer.cancel();
    Provider.of<GameService>(context, listen: false).endGame();
    Provider.of<MousePositioningService>(context, listen: false).stopMovement();
    Provider.of<CatPositioningService>(context, listen: false)
        .resetCatPosition();
    Provider.of<DogsPositioningService>(context, listen: false)
        .stopDogsAnimation();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const GameOverDialog();
      },
    );
  }
}
