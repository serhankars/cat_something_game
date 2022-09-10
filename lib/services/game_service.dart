import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'dogs_positioning_service.dart';
import 'mouse_positioning_service.dart';

class GameService extends ChangeNotifier {
  int numberOfDogs = 3;
  int durationBetweenPointsForCat = 2;
  int durationBetweenPointsForMouse = 2;
  int durationBetweenPointsForDogs = 2;
  bool isGameStarted = false;
  late Timer autonumousItemsTimer;

  int totalMouseCatched = 0;

  void initTimer(BuildContext context) {
    totalMouseCatched = 0;
    autonumousItemsTimer = Timer.periodic(
        Duration(seconds: durationBetweenPointsForDogs), (timer) {
      if (!isGameStarted) {
        return;
      }

      Provider.of<DogsPositioningService>(context, listen: false)
          .updateDogsTargets();

      Provider.of<MousePositioningService>(context, listen: false)
          .resetTarget();
    });
  }

  void endGame() {
    isGameStarted = false;
    autonumousItemsTimer.cancel();
  }

  void onMouseCatched() {
    totalMouseCatched++;
    notifyListeners();
  }
}
