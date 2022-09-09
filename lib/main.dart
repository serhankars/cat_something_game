import 'package:cat_something_game/pages/menu_page.dart';
import 'package:cat_something_game/services/cat_positioning_service.dart';
import 'package:cat_something_game/services/collision_service.dart';
import 'package:cat_something_game/services/dogs_positioning_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'pages/game_page.dart';
import 'services/game_service.dart';
import 'services/mouse_positioning_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameService>(create: (context) => GameService()),
        ChangeNotifierProvider<CatPositioningService>(
            create: (context) => CatPositioningService()),
        ChangeNotifierProvider<MousePositioningService>(
            create: (context) => MousePositioningService()),
        ChangeNotifierProvider<DogsPositioningService>(
            create: (context) => DogsPositioningService()),
        ChangeNotifierProvider<CollisionService>(
            create: (context) => CollisionService()),
      ],
      child: MaterialApp(
        title: 'Cat something',
        theme: ThemeData(
          fontFamily: 'BitmapFont',
          primarySwatch: Colors.blue,
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              shape: const MaterialStatePropertyAll(StadiumBorder()),
              side: MaterialStateProperty.resolveWith<BorderSide>((states) {
                if (states.contains(MaterialState.hovered) ||
                    states.contains(MaterialState.pressed)) {
                  return const BorderSide(color: Colors.white);
                }

                return const BorderSide(color: Colors.black);
              }),
              foregroundColor: MaterialStateProperty.resolveWith<Color>(
                (states) {
                  if (states.contains(MaterialState.hovered) ||
                      states.contains(MaterialState.pressed)) {
                    return Colors.white;
                  }
                  return Colors.black;
                },
              ),
              textStyle: MaterialStateProperty.resolveWith<TextStyle>(
                (states) {
                  if (states.contains(MaterialState.hovered) ||
                      states.contains(MaterialState.pressed)) {
                    return const TextStyle(
                      fontFamily: 'BitmapFont',
                      fontSize: 25,
                    );
                  }
                  return const TextStyle(
                    fontFamily: 'BitmapFont',
                    fontSize: 24,
                  );
                },
              ),
            ),
          ),
        ),
        initialRoute: MenuPage.route,
        routes: {
          MenuPage.route: (context) => const MenuPage(),
          GamePage.route: (context) => const GamePage()
        },
      ),
    );
  }
}
