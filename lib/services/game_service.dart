import 'package:flutter/foundation.dart';

class GameService extends ChangeNotifier {
  int numberOfDogs = 3;
  int durationBetweenPointsForCat = 2;
  int durationBetweenPointsForMouse = 2;
  int durationBetweenPointsForKillers = 2;
  bool isGameStarted = false;
}
