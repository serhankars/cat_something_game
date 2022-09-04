import "package:flutter/material.dart";

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  Alignment _oldAlignment = const Alignment(0, 0);
  Alignment _nextAlignment = const Alignment(0, 0);
  double screenWidth = 0;
  double screenHeight = 0;
  late AnimationController _ac;

  @override
  void initState() {
    _ac =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GestureDetector(
        onTapDown: (details) {
          double horizontalAlignment =
              (details.globalPosition.dx - (screenWidth / 2)) /
                  (screenWidth / 2);
          double verticalAlignment =
              (details.globalPosition.dy - (screenHeight / 2)) /
                  (screenHeight / 2);
          _oldAlignment =
              AlignmentTween(begin: _oldAlignment, end: _nextAlignment)
                  .evaluate(_ac);
          _nextAlignment = Alignment(horizontalAlignment, verticalAlignment);
          _ac.reset();
          _ac.forward();

          setState(() {});
        },
        child: Container(
          color: Colors.yellow,
          constraints: BoxConstraints.expand(),
          child: AlignTransition(
            alignment: AlignmentTween(begin: _oldAlignment, end: _nextAlignment)
                .animate(_ac),
            child: Container(
              width: 10,
              height: 10,
              color: Colors.red,
            ),
          ),
        ),
      ),
    );
  }
}
