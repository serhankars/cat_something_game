import 'package:flutter/cupertino.dart';
import '../helpers/positioning_helpers.dart';

class DogsPositioningService extends ChangeNotifier {
  late List<Alignment> previousAlignmentsList;
  late List<Alignment> nextAlignmentsList;
  late int _numberOfDogs;
  late AnimationController dogsAnimationController;

  void initializeDogsPositions(int numberOfDogs, AnimationController dogsAC) {
    _numberOfDogs = numberOfDogs;
    dogsAnimationController = dogsAC;
    previousAlignmentsList = [
      for (int i = 0; i < _numberOfDogs; i++)
        PositioningHelpers.generateRandomAlignment()
    ];

    nextAlignmentsList = [...previousAlignmentsList];
  }

  void updateDogsTargets() {
    previousAlignmentsList = nextAlignmentsList;
    nextAlignmentsList = [
      for (int i = 0; i < _numberOfDogs; i++)
        PositioningHelpers.generateRandomAlignment()
    ];
    dogsAnimationController.reset();
    dogsAnimationController.forward();

    notifyListeners();
  }

  void stopDogsAnimation() {
    dogsAnimationController.reset();
    dogsAnimationController.stop();
  }
}
