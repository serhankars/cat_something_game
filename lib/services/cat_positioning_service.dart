import 'package:flutter/material.dart';

class CatPositioningService extends ChangeNotifier {
  late AnimationController _animationController;
  Alignment oldAlignment = const Alignment(0, 0);
  Alignment nextAlignment = const Alignment(0, 0);

  void setAnimationController(AnimationController animationController) {
    _animationController = animationController;
  }

  void setTargetAlignment(Alignment targetAlignment) {
    oldAlignment = AlignmentTween(begin: oldAlignment, end: nextAlignment)
        .evaluate(_animationController);
    nextAlignment = targetAlignment;
    _animationController.reset();
    _animationController.forward();
    notifyListeners();
  }

  Alignment getCurrentAlignment() {
    return AlignmentTween(begin: oldAlignment, end: nextAlignment)
        .evaluate(_animationController);
  }

  void resetCatPosition() {
    oldAlignment = const Alignment(0, 0);
    nextAlignment = const Alignment(0, 0);
    _animationController.reset();
    notifyListeners();
  }
}
