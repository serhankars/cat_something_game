import 'package:cat_something_game/services/dogs_positioning_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Dog extends StatelessWidget {
  final int dogIndex;
  const Dog({super.key, required this.dogIndex});

  @override
  Widget build(BuildContext context) {
    return Consumer<DogsPositioningService>(
        builder: (context, dogsPositioningService, child) {
      return AlignTransition(
        alignment: AlignmentTween(
                begin: dogsPositioningService.previousAlignmentsList[dogIndex],
                end: dogsPositioningService.nextAlignmentsList[dogIndex])
            .animate(dogsPositioningService.dogsAnimationController),
        child: Image.asset(
          "assets/images/dog.png",
          width: 50,
          height: 50,
        ),
      );
    });
  }
}
