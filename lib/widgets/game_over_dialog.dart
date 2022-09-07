import 'package:cat_something_game/pages/game_page.dart';
import 'package:cat_something_game/pages/menu_page.dart';
import 'package:flutter/material.dart';

class GameOverDialog extends StatelessWidget {
  const GameOverDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      insetAnimationDuration: const Duration(seconds: 5),
      insetAnimationCurve: Curves.easeIn,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.transparent),
            borderRadius: BorderRadius.circular(20),
            gradient: const RadialGradient(
              tileMode: TileMode.clamp,
              radius: 0.8,
              colors: [
                // Colors.white,
                Color.fromARGB(255, 127, 217, 163),
                Color.fromARGB(255, 9, 88, 3),
              ],
            )),
        height: 250,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const FittedBox(
              alignment: Alignment.center,
              fit: BoxFit.scaleDown,
              child: Text(
                "GAME OVER!",
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(GamePage.route);
                },
                child: const Text(
                  "TRY AGAIN",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              width: 200,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacementNamed(MenuPage.route);
                },
                child: const Text(
                  "RETURN TO MENU",
                  style: TextStyle(fontSize: 17),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
