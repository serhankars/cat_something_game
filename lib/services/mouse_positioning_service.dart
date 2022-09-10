import 'package:cat_something_game/helpers/positioning_helpers.dart';
import 'package:flutter/cupertino.dart';

class MousePositioningService extends ChangeNotifier {
  late AnimationController _animationController;
  late Alignment oldAlignment;
  late Alignment nextAlignment;

  Alignment getCurrentAlignment() {
    Alignment currentAlignment =
        AlignmentTween(begin: oldAlignment, end: nextAlignment)
            .evaluate(_animationController);

    return currentAlignment;
  }

  void setAnimationController(AnimationController animationController) {
    _animationController = animationController;
  }

  void stopMovement() {
    _animationController.reset();
    _animationController.stop();
    notifyListeners();
  }

  void resetPosition() {
    oldAlignment = PositioningHelpers.generateRandomAlignment();
    nextAlignment = oldAlignment;
    _animationController.reset();
    notifyListeners();
  }

  void resetTarget() {
    oldAlignment = nextAlignment;
    nextAlignment = PositioningHelpers.generateRandomAlignment();
    _animationController.reset();
    _animationController.forward();
    notifyListeners();
  }
}
