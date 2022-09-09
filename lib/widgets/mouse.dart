import 'package:cat_something_game/helpers/positioning_helpers.dart';
import 'package:cat_something_game/services/mouse_positioning_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/game_service.dart';

class Mouse extends StatefulWidget {
  const Mouse({super.key});

  @override
  State<Mouse> createState() => _MouseState();
}

class _MouseState extends State<Mouse> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  @override
  void initState() {
    int durationBetweenPointsForMouse =
        Provider.of<GameService>(context, listen: false)
            .durationBetweenPointsForMouse;

    _animationController = AnimationController(
        vsync: this,
        duration: Duration(seconds: durationBetweenPointsForMouse));

    Provider.of<MousePositioningService>(context, listen: false)
        .setAnimationController(_animationController);

    Alignment alignment = PositioningHelpers.generateRandomAlignment();
    Provider.of<MousePositioningService>(context, listen: false).oldAlignment =
        alignment;
    Provider.of<MousePositioningService>(context, listen: false).nextAlignment =
        alignment;

    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MousePositioningService>(
        builder: (context, mousePositioningService, child) {
      return AlignTransition(
        alignment: AlignmentTween(
                begin: mousePositioningService.oldAlignment,
                end: mousePositioningService.nextAlignment)
            .animate(_animationController),
        child: Image.asset(
          "assets/images/mouse.png",
          width: 50,
          height: 50,
        ),
      );
    });
  }
}
